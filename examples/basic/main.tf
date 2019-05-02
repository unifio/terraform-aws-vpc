# AWS Virtual Private Cloud

## Configures AWS provider
provider "aws" {
  region = var.region
}

## Configures base VPC
module "vpc_base" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//base"
  source = "../../base"

  enable_dns          = var.enable_dns
  enable_hostnames    = var.enable_hostnames
  stack_item_fullname = var.stack_item_fullname
  stack_item_label    = var.stack_item_label
  vpc_cidr            = var.vpc_cidr
}

## Configures DHCP
module "vpc_dhcp" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//dhcp"
  source = "../../dhcp"

  domain_name         = var.domain_name
  stack_item_fullname = var.stack_item_fullname
  stack_item_label    = var.stack_item_label
  vpc_id              = module.vpc_base.vpc_id
}

## Configures VPC Availabilty Zones
module "vpc_az" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//az"
  source = "../../az"

  azs_provisioned       = var.azs_provisioned
  enable_dmz_public_ips = var.enable_dmz_public_ips
  lans_per_az           = var.lans_per_az
  nat_eips_enabled      = var.nat_eips_enabled
  rt_dmz_id             = module.vpc_base.rt_dmz_id
  stack_item_fullname   = var.stack_item_fullname
  stack_item_label      = var.stack_item_label
  vpc_id                = module.vpc_base.vpc_id
}

## Configures Virtual Private Gateway
module "vpc_vpg" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//vpg"
  source = "../../vpg"

  stack_item_fullname = var.stack_item_fullname
  stack_item_label    = var.stack_item_label
  vpc_attach          = var.vpc_attach
  vpc_id              = module.vpc_base.vpc_id
}

## Configures routing
resource "aws_route" "dmz-to-igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc_base.igw_id
  route_table_id         = module.vpc_base.rt_dmz_id
}

resource "aws_route" "lan-to-nat" {
  count = var.azs_provisioned * var.lans_per_az

  destination_cidr_block = "0.0.0.0/0"
  instance_id            = element(module.vpc_az.nat_ids, count.index)
  route_table_id         = element(module.vpc_az.rt_lan_ids, count.index)
}

