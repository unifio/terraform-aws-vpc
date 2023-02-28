# VPC base

## Set Terraform version constraint
terraform {
  required_version = "> 0.11.0"
}

## Set default instance tennancy if not provided
locals {
  default_instance_tenancy = length(var.instance_tenancy) >= 1 ? var.instance_tenancy : "default"

  default_vpc_tags = {
    application = var.stack_item_fullname
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-vpc"
  }
}

## Provisions Virtual Private Cloud (VPC)
resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr
  instance_tenancy                 = local.default_instance_tenancy
  enable_dns_support               = var.enable_dns
  enable_dns_hostnames             = var.enable_hostnames
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.assign_generated_ipv6_cidr_block

  tags = merge(local.default_vpc_tags, var.additional_vpc_tags)
}

## Provisions Internet gateways
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    application = var.stack_item_fullname
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-igw"
  }
}

## Provisions DMZ routing table
resource "aws_route_table" "rt_dmz" {
  propagating_vgws = var.propagate_vgws ? compact(var.vgw_ids) : null
  vpc_id           = aws_vpc.vpc.id

  tags = {
    application = var.stack_item_fullname
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-dmz"
  }
}
