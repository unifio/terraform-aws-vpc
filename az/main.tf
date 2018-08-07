# VPC availability zone

## Set Terraform version constraint
terraform {
  required_version = "> 0.11.0"
}

## Variables
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

locals {
  # Calculates the number of AZs to be provisioned based on various possible inputs
  azs_provisioned_count = "${local.azs_provisioned_override_enabled == "true" ? length(var.azs_provisioned_override) : var.azs_provisioned}"

  # Check to see if availability zones are being overridden. Some AWS regions do not support VPC in all AZs and it can vary by account.
  azs_provisioned_override_enabled = "${length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? "true" : "false"}"

  # Check to see if DMZ CIDRs are being overridden. An empty list causes problems in some of the downstream formualtion.
  dmz_cidrs_override_enabled = "${length(var.dmz_cidrs_override) > 0 && var.dmz_cidrs_override[0] != "non_empty_list" ? "true" : "false"}"

  # Check to see if elastic IPs are to be provisioned. NAT gateways require EIPs.
  eips_enabled_check = "${var.nat_eips_enabled == "true" || var.nat_gateways_enabled == "true" ? 1 : 0}"

  # Check to see if private LAN subnets are to be provisioned.
  lans_enabled_check = "${local.lans_per_az_checked > 0 ? 1 : 0}"

  # Check to see if LAN CIDRs are being overridden. An empty list causes problems in some of the downstream formualtion.
  lan_cidrs_override_enabled = "${length(var.lan_cidrs_override) > 0 && var.lan_cidrs_override[0] != "non_empty_list" ? "true" : "false"}"

  # Multiplier to be used in downstream calculation based on the number of LAN subnets per AZ.
  lans_multiplier = "${local.lans_per_az_checked >= 0 ? local.lans_per_az_checked : 1}"

  # Handles scenario where an emptry string is passed in for lans_per_az
  lans_per_az_checked = "${var.lans_per_az != "" ? var.lans_per_az : "1"}"

  # Check to see if NAT gateways are to be provisioned
  nat_gateways_enabled_check = "${var.nat_gateways_enabled == "true" ? 1 : 0}"

  # Check to see if NAT gateways are NOT to be provisioned
  nat_gateways_not_enabled_check = "${var.nat_gateways_enabled != "true" ? 1 : 0}"

  # default subnet tags
  default_subnet_tags = [
    {
      application = "${var.stack_item_fullname}"
      managed_by  = "terraform"
    },
  ]
}

## Provisions DMZ resources

### Provisions subnets

data "aws_vpc" "base" {
  id = "${var.vpc_id}"
}

resource "aws_subnet" "dmz" {
  count = "${local.azs_provisioned_count}"

  # Selects the first N number of AZs available for VPC use in the given region, where N is the requested number of AZs to provision. This order can be overidden by passing in an explicit list of AZ letters to be used.
  availability_zone = "${local.azs_provisioned_override_enabled == "true" ? "${data.aws_region.current.name}${element(var.azs_provisioned_override,count.index)}" : element(data.aws_availability_zones.available.names,count.index)}"

  # Provisions N number of evenly allocated address spaces from the overall VPC CIDR block, where N is the requested number of AZs to provision. Address space per subnet can be overidden by passing in an explicit list of CIDRs to be used.
  cidr_block              = "${local.dmz_cidrs_override_enabled == "true" ? element(var.dmz_cidrs_override,count.index) : cidrsubnet(data.aws_vpc.base.cidr_block,lookup(var.az_cidrsubnet_newbits, local.azs_provisioned_count),count.index)}"
  map_public_ip_on_launch = "${var.enable_dmz_public_ips}"
  vpc_id                  = "${var.vpc_id}"

  tags = "${concat(local.default_subnet_tags, var.additional_subnet_tags, list(map("Name", "${var.stack_item_label}-dmz-${count.index}")))}"
}

### Associates subnet with routing table
resource "aws_route_table_association" "rta_dmz" {
  count = "${local.azs_provisioned_count}"

  route_table_id = "${var.rt_dmz_id}"
  subnet_id      = "${element(aws_subnet.dmz.*.id,count.index)}"
}

### Provisions NATs
data "aws_ami" "nat_ami" {
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_eip" "eip_nat" {
  count = "${local.azs_provisioned_count * local.lans_enabled_check * local.eips_enabled_check}"

  vpc = true
}

resource "aws_eip_association" "eip_nat_assoc" {
  count = "${local.azs_provisioned_count * local.lans_enabled_check * local.eips_enabled_check * local.nat_gateways_not_enabled_check}"

  allocation_id = "${element(aws_eip.eip_nat.*.id,count.index)}"
  instance_id   = "${element(aws_instance.nat.*.id,count.index)}"
}

resource "aws_instance" "nat" {
  count = "${local.azs_provisioned_count * local.lans_enabled_check * local.nat_gateways_not_enabled_check}"

  ami                         = "${coalesce(var.nat_ami_override,data.aws_ami.nat_ami.id)}"
  associate_public_ip_address = true
  instance_type               = "${var.nat_instance_type}"
  key_name                    = "${var.nat_key_name}"
  source_dest_check           = false
  subnet_id                   = "${element(aws_subnet.dmz.*.id,count.index)}"
  vpc_security_group_ids      = ["${element(aws_security_group.sg_nat.*.id,count.index)}"]

  tags {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-nat-${count.index}"
  }
}

resource "aws_security_group" "sg_nat" {
  count = "${local.azs_provisioned_count * local.lans_enabled_check * local.nat_gateways_not_enabled_check}"

  description = "${var.stack_item_fullname} NAT security group"
  name_prefix = "${var.stack_item_label}-nat-"
  vpc_id      = "${var.vpc_id}"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Egress to the Internet"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["${local.lan_cidrs_override_enabled == "true" ? element(var.lan_cidrs_override,count.index) : cidrsubnet(data.aws_vpc.base.cidr_block,lookup(var.az_cidrsubnet_newbits, local.azs_provisioned_count * local.lans_multiplier),count.index + lookup(var.az_cidrsubnet_offset, local.azs_provisioned_count))}"]
    description = "Ingress from ${var.stack_item_label}-lan-${count.index}"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-nat-${count.index}"
  }
}

resource "aws_nat_gateway" "nat" {
  count = "${local.azs_provisioned_count * local.lans_enabled_check * local.nat_gateways_enabled_check}"

  allocation_id = "${element(aws_eip.eip_nat.*.id,count.index)}"
  subnet_id     = "${element(aws_subnet.dmz.*.id,count.index)}"
}

###

## Provisions LAN resources

### Provisions subnet
resource "aws_subnet" "lan" {
  count = "${local.azs_provisioned_count * local.lans_multiplier}"

  # Selects the first N number of AZs available for VPC use in the given region, where N is the requested number of AZs to provision. This order can be overidden by passing in an explicit list of AZ letters to be used.
  availability_zone = "${local.azs_provisioned_override_enabled == "true" ? "${data.aws_region.current.name}${element(var.azs_provisioned_override,count.index)}" : element(data.aws_availability_zones.available.names,count.index)}"

  # Provisions N number of evenly allocated address spaces from the overall VPC CIDR block, where N is the requested number of AZs to provision multiplied by the number of LAN subnets to provision per AZ. Address space per subnet can be overidden by passing in an explicit list of CIDRs to be used.
  cidr_block = "${local.lan_cidrs_override_enabled == "true" ? element(var.lan_cidrs_override,count.index) : cidrsubnet(data.aws_vpc.base.cidr_block,lookup(var.az_cidrsubnet_newbits, local.azs_provisioned_count * local.lans_multiplier),count.index + lookup(var.az_cidrsubnet_offset, local.azs_provisioned_count))}"
  vpc_id     = "${var.vpc_id}"

  tags = "${concat(local.default_subnet_tags, var.additional_subnet_tags, list(map("Name", "${var.stack_item_label}-lan-${count.index}")))}"
}

### Provisions routing table
resource "aws_route_table" "rt_lan" {
  count = "${local.azs_provisioned_count * local.lans_multiplier}"

  propagating_vgws = ["${compact(var.vgw_ids)}"]
  vpc_id           = "${var.vpc_id}"

  tags {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-lan-${count.index}"
  }
}

### Associates subnet with routing table
resource "aws_route_table_association" "rta_lan" {
  count = "${local.azs_provisioned_count * local.lans_multiplier}"

  route_table_id = "${element(aws_route_table.rt_lan.*.id,count.index)}"
  subnet_id      = "${element(aws_subnet.lan.*.id,count.index)}"
}
