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

  enable_classiclink  = var.enable_classiclink
  enable_hostnames    = var.enable_hostnames
  instance_tenancy    = var.instance_tenancy
  stack_item_fullname = var.stack_item_fullname
  stack_item_label    = var.stack_item_label
  vpc_cidr            = var.vpc_cidr
}

## Configures DHCP
module "vpc_dhcp" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//dhcp"
  source = "../../dhcp"

  domain_name          = var.domain_name
  name_servers         = [var.name_servers]
  netbios_name_servers = [var.netbios_name_servers]
  netbios_node_type    = var.netbios_node_type
  ntp_servers          = [var.ntp_servers]
  stack_item_fullname  = var.stack_item_fullname
  stack_item_label     = var.stack_item_label
  vpc_id               = module.vpc_base.vpc_id
}

## Configures ACLs
resource "aws_network_acl" "acl" {
  vpc_id = module.vpc_base.vpc_id
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  subnet_ids = [concat(module.vpc_az.lan_ids, module.vpc_az.dmz_ids)]

  tags = {
    application = var.stack_item_fullname
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-acl"
  }
}

## Configures Virtual Private Gateway
module "vpc_vpg" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//vpg"
  source = "../../vpg"

  vpc_attach          = "true"
  vpc_id              = module.vpc_base.vpc_id
  stack_item_fullname = var.stack_item_fullname
  stack_item_label    = var.stack_item_label
}

module "vpc_az" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//az"
  source = "../../az"

  azs_provisioned_override = var.azs_provisioned_override

  dmz_cidrs_override = [
    cidrsubnet(var.vpc_cidr, 3, 0),
    cidrsubnet(var.vpc_cidr, 3, 1),
    cidrsubnet(var.vpc_cidr, 3, 2),
    cidrsubnet(var.vpc_cidr, 3, 3),
  ]

  lan_cidrs_override = [
    cidrsubnet(var.vpc_cidr, 4, 8),
    cidrsubnet(var.vpc_cidr, 4, 9),
    cidrsubnet(var.vpc_cidr, 4, 10),
    cidrsubnet(var.vpc_cidr, 4, 11),
    cidrsubnet(var.vpc_cidr, 4, 12),
    cidrsubnet(var.vpc_cidr, 4, 13),
    cidrsubnet(var.vpc_cidr, 4, 14),
    cidrsubnet(var.vpc_cidr, 4, 15),
  ]

  lans_per_az          = var.lans_per_az
  nat_eips_enabled     = "false"
  nat_gateways_enabled = var.nat_gateways_enabled
  rt_dmz_id            = module.vpc_base.rt_dmz_id
  stack_item_label     = var.stack_item_label
  stack_item_fullname  = var.stack_item_fullname
  vgw_ids              = [module.vpc_vpg.vpg_id]
  vpc_id               = module.vpc_base.vpc_id
}

## Configures routing
resource "aws_route" "dmz-to-igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.vpc_base.igw_id
  route_table_id         = module.vpc_base.rt_dmz_id
}

resource "aws_route" "lan-to-nat-gw" {
  count = length(var.azs_provisioned_override) * length(var.lans_per_az) > 0 ? var.lans_per_az : "1" * signum(var.nat_gateways_enabled == "true" ? "1" : "0")

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(module.vpc_az.nat_ids, count.index)
  route_table_id         = element(module.vpc_az.rt_lan_ids, count.index)
}

resource "aws_route" "lan-to-nat" {
  count = length(var.azs_provisioned_override) * length(var.lans_per_az) > 0 ? var.lans_per_az : "1" * signum(var.nat_gateways_enabled == "true" ? "0" : "1")

  destination_cidr_block = "0.0.0.0/0"
  instance_id            = element(module.vpc_az.nat_ids, count.index)
  route_table_id         = element(module.vpc_az.rt_lan_ids, count.index)
}

resource "aws_vpc_endpoint" "s3-ep" {
  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibilty in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  route_table_ids = [module.vpc_az.rt_lan_ids]
  service_name    = "com.amazonaws.${var.region}.s3"
  vpc_id          = module.vpc_base.vpc_id
}

