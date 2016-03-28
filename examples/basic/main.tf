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
  enable_dns = "${var.enable_dns}"
  enable_hostnames = "${var.enable_hostnames}"
  lan_cidr = "${var.lan_access_cidr}"
}
}

## Configures VPC Availabilty Zones
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
}
