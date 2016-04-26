# AWS Virtual Private Cloud

## Configures AWS provider
provider "aws" {
  region = "${var.region}"
}

## Configures base VPC
module "vpc_base" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//base"
  source = "../../base"

  stack_item_label = "${var.stack_item_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
  vpc_cidr = "${var.vpc_cidr}"
}

## Configures DHCP
module "vpc_dhcp" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//dhcp"
  source = "../../dhcp"

  stack_item_label = "${var.stack_item_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
  vpc_id = "${module.vpc_base.vpc_id}"
  domain_name = "${var.domain_name}"
  name_servers = "${var.name_servers}"
  ntp_servers = "${var.ntp_servers}"
  netbios_name_servers = "${var.netbios_name_servers}"
  netbios_node_type = "${var.netbios_node_type}"
}

## Configures ACLs
resource "aws_network_acl" "acl" {
  vpc_id = "${module.vpc_base.vpc_id}"
  subnet_ids = ["${split(",","${module.vpc_az.lan_id},${module.vpc_az.dmz_id}")}"]

  tags {
    Name = "${var.stack_item_label}-acl"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
}

## Configures Virtual Private Gateway
module "vpc_vpg" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//vpg"
  source = "../../vpg"

  vpc_id = "${module.vpc_base.vpc_id}"
  stack_item_label = "${var.stack_item_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
}

module "vpc_az" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//az"
  source = "../../az"

  stack_item_label = "${var.stack_item_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
  vpc_id = "${module.vpc_base.vpc_id}"
  region = "${var.region}"
  az = "${lookup(var.az,var.region)}"
  dmz_cidr = "${cidrsubnet(var.vpc_cidr,4,0)},${cidrsubnet(var.vpc_cidr,4,1)},${cidrsubnet(var.vpc_cidr,4,2)},${cidrsubnet(var.vpc_cidr,4,3)}"
  lan_cidr = "${cidrsubnet(var.vpc_cidr,4,8)},${cidrsubnet(var.vpc_cidr,4,9)},${cidrsubnet(var.vpc_cidr,4,10)},${cidrsubnet(var.vpc_cidr,4,13)},${cidrsubnet(var.vpc_cidr,4,14)},${cidrsubnet(var.vpc_cidr,4,15)}"
  lans_per_az = "${var.lans_per_az}"
  rt_dmz_id = "${module.vpc_base.rt_dmz_id}"
}

## Configures routing
resource "aws_route" "dmz-to-igw" {
  count = "${length(split(",",lookup(var.az,var.region)))}"
  route_table_id = "${module.vpc_base.rt_dmz_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${module.vpc_base.igw_id}"
}

resource "aws_route" "lan-to-nat"{
  count = "${length(split(",",lookup(var.az,var.region))) * var.lans_per_az}"
  route_table_id = "${element(split(",",module.vpc_az.rt_lan_id),count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${element(split(",",module.vpc_az.nat_id),count.index)}"
}

resource "aws_vpc_endpoint" "s3-ep" {
    vpc_id = "${module.vpc_base.vpc_id}"
    service_name = "com.amazonaws.${var.region}.s3"
    route_table_ids = ["${split(",","${module.vpc_az.lan_id}")}"]
}
