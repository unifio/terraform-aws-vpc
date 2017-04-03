# VPC availability zone

## Set Terraform version constraint
terraform {
  required_version = "> 0.8.0"
}

## Provisions DMZ resources

### Provisions subnets
data "aws_region" "current" {
  current = true
}

data "aws_availability_zones" "available" {}

data "aws_vpc" "base" {
  id = "${var.vpc_id}"
}

resource "aws_subnet" "dmz" {
  count = "${length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned}"

  availability_zone       = "${length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? "${data.aws_region.current.name}${element(var.azs_provisioned_override,count.index)}" : element(data.aws_availability_zones.available.names,count.index)}"
  cidr_block              = "${length(var.dmz_cidrs) > 0 && var.dmz_cidrs[0] != "non_empty_list" ? element(var.dmz_cidrs,count.index) : cidrsubnet(data.aws_vpc.base.cidr_block,lookup(var.az_cidrsubnet_newbits, length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned),count.index)}"
  map_public_ip_on_launch = "${var.enable_dmz_public_ips}"
  vpc_id                  = "${var.vpc_id}"

  tags {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-dmz-${count.index}"
  }
}

### Associates subnet with routing table
resource "aws_route_table_association" "rta_dmz" {
  count = "${length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned}"

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
  count = "${(length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * signum(length(var.lans_per_az) > 0 ? var.lans_per_az : "1") * signum(var.nat_eips_enabled == "true" || var.nat_gateways_enabled == "true" ? "1" : "0")}"

  vpc = true
}

resource "aws_eip_association" "eip_nat_assoc" {
  count = "${(length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * signum(length(var.lans_per_az) > 0 ? var.lans_per_az : "1") * signum(var.nat_eips_enabled == "true" && var.nat_gateways_enabled != "true" ? "1" : "0")}"

  allocation_id = "${element(aws_eip.eip_nat.*.id,count.index)}"
  instance_id   = "${element(aws_instance.nat.*.id,count.index)}"
}

resource "aws_instance" "nat" {
  count = "${(length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * signum(length(var.lans_per_az) > 0 ? var.lans_per_az : "1") * signum(var.nat_gateways_enabled != "true" ? "1" : "0")}"

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
  count = "${(length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * signum(length(var.lans_per_az) > 0 ? var.lans_per_az : "1") * signum(var.nat_gateways_enabled != "true" ? "1" : "0")}"

  description = "${var.stack_item_fullname} NAT security group"
  name_prefix = "${var.stack_item_label}-nat-"
  vpc_id      = "${var.vpc_id}"

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["${length(var.lan_cidrs) > 0 && var.lan_cidrs[0] != "non_empty_list" ? element(var.lan_cidrs,count.index) : cidrsubnet(data.aws_vpc.base.cidr_block,lookup(var.az_cidrsubnet_newbits, (length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * (length(var.lans_per_az) > 0 ? var.lans_per_az : "1")),count.index + lookup(var.az_cidrsubnet_offset, length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned))}"]
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
  count = "${(length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * signum(length(var.lans_per_az) > 0 ? var.lans_per_az : "1") * signum(var.nat_gateways_enabled == "true" ? "1" : "0")}"

  allocation_id = "${element(aws_eip.eip_nat.*.id,count.index)}"
  subnet_id     = "${element(aws_subnet.dmz.*.id,count.index)}"
}

###

## Provisions LAN resources

### Provisions subnet
resource "aws_subnet" "lan" {
  count = "${(length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * (length(var.lans_per_az) > 0 ? var.lans_per_az : "1")}"

  availability_zone = "${length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? "${data.aws_region.current.name}${element(var.azs_provisioned_override,count.index)}" : element(data.aws_availability_zones.available.names,count.index)}"
  cidr_block        = "${length(var.lan_cidrs) > 0 && var.lan_cidrs[0] != "non_empty_list" ? element(var.lan_cidrs,count.index) : cidrsubnet(data.aws_vpc.base.cidr_block,lookup(var.az_cidrsubnet_newbits, (length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * (length(var.lans_per_az) > 0 ? var.lans_per_az : "1")),count.index + (lookup(var.az_cidrsubnet_offset, length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * (length(var.lans_per_az) > 0 ? var.lans_per_az : "1")))}"
  vpc_id            = "${var.vpc_id}"

  tags {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-lan-${count.index}"
  }
}

### Provisions routing table
resource "aws_route_table" "rt_lan" {
  count = "${(length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * (length(var.lans_per_az) > 0 ? var.lans_per_az : "1")}"

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
  count = "${(length(var.azs_provisioned_override) > 0 && var.azs_provisioned_override[0] != "non_empty_list" ? length(var.azs_provisioned_override) : var.azs_provisioned) * (length(var.lans_per_az) > 0 ? var.lans_per_az : "1")}"

  route_table_id = "${element(aws_route_table.rt_lan.*.id,count.index)}"
  subnet_id      = "${element(aws_subnet.lan.*.id,count.index)}"
}
