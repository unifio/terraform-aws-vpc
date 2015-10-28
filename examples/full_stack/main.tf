# AWS VPC

provider "aws" {
  region = "${var.region}"
}

module "vpc_base" {
  source = "github.com/unifio/terraform-aws-vpc//base"

  stack_item_label = "${var.stack_item_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
  vpc_cidr = "${var.vpc_cidr}"
  enable_dns = "${var.enable_dns}"
  enable_hostnames = "${var.enable_hostnames}"
  lan_cidr = "${var.lan_access_cidr}"
}

module "vpc_dhcp" {
  source = "github.com/unifio/terraform-aws-vpc//dhcp"

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
  source = "github.com/unifio/terraform-aws-vpc//vpg"

  vpc_id = "${module.vpc_base.vpc_id}"
  stack_item_label = "${var.stack_item_label}"
  stack_item_fullname = "${var.stack_item_fullname}"
}

module "vpc_az" {
  source = "github.com/unifio/terraform-aws-vpc//az"

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
  user_data_template = "${var.user_data_template}"
  domain = "${var.domain_name}"
  ssh_user = "${var.ssh_user}"
  nat_auto_recovery = "${var.nat_auto_recovery}"
}
