# AWS VPC

provider "aws" {
  region = "${var.region}"
}

module "vpc_base" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//base"
  source = "../../base"

  stack_item_label = "${var.stack_item_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
  vpc_cidr = "${var.vpc_cidr}"
  enable_dns = "${var.enable_dns}"
  enable_hostnames = "${var.enable_hostnames}"
  lan_cidr = "${var.lan_access_cidr}"
}

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
  netbios_node_type = 2
}

module "vpc_vpg" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//vpg"
  source = "../../vpg"

  vpc_id = "${module.vpc_base.vpc_id}"
  stack_item_label = "${var.stack_item_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
}

## Generates instance user data from a template
resource "template_file" "user_data" {
  template = "${file("../templates/user_data.tpl")}"

  vars {
    hostname = "${var.stack_item_label}-example"
    fqdn = "${var.stack_item_label}-nat.${var.domain_name}"
    ssh_user = "{var.ssh_user}"
  }
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
  dmz_cidr = "${var.dmz_cidr}"
  lan_cidr = "${var.lan_cidr}"
  lans_per_az = "${var.lans_per_az}"
  enable_dmz_public_ips = "${var.enable_dmz_public_ips}"
  rt_dmz_id = "${module.vpc_base.rt_dmz_id}"
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  nat_sg_id = "${module.vpc_base.nat_sg_id}"
  user_data = "${template_file.user_data.rendered}"
  enable_nat_auto_recovery = "${var.enable_nat_auto_recovery}"
  enable_nat_eip = "${var.enable_nat_eip}"
}
