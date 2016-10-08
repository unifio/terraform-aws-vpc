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

  stack_item_label    = "${var.stack_item_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
  vpc_cidr            = "${var.vpc_cidr}"
  enable_dns          = "${var.enable_dns}"
  enable_hostnames    = "${var.enable_hostnames}"
}

## Configures VPC Availabilty Zones
module "vpc_az" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//az"
  source = "../../az"

  stack_item_label      = "${var.stack_item_label}"
  stack_item_fullname   = "${var.stack_item_fullname}"
  vpc_id                = "${module.vpc_base.vpc_id}"
  region                = "${var.region}"
  az                    = "${lookup(var.az,var.region)}"
  dmz_cidr              = "${cidrsubnet(var.vpc_cidr,3,0)},${cidrsubnet(var.vpc_cidr,3,1)},${cidrsubnet(var.vpc_cidr,3,2)}"
  lan_cidr              = "${cidrsubnet(var.vpc_cidr,3,4)},${cidrsubnet(var.vpc_cidr,3,5)},${cidrsubnet(var.vpc_cidr,3,6)}"
  lans_per_az           = "${var.lans_per_az}"
  enable_dmz_public_ips = "${var.enable_dmz_public_ips}"
  rt_dmz_id             = "${module.vpc_base.rt_dmz_id}"
}

## Configures Virtual Private Gateway
module "vpc_vpg" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//vpg"
  source = "../../vpg"

  stack_item_label    = "${var.stack_item_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
  vpc_attach          = "${var.vpg_vpc_attach}"
  vpc_id              = "${module.vpc_base.vpc_id}"
}

## Configures routing
resource "aws_route" "dmz-to-igw" {
  route_table_id         = "${module.vpc_base.rt_dmz_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${module.vpc_base.igw_id}"
}

resource "aws_route" "lan-to-nat" {
  count                  = "${length(split(",",lookup(var.az,var.region))) * var.lans_per_az}"
  route_table_id         = "${element(split(",",module.vpc_az.rt_lan_id),count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(split(",",module.vpc_az.nat_id),count.index)}"
}
