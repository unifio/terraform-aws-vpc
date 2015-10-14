# VPC Base

## Provisions Virtual Private Cloud (VPC)
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = "${var.enable_dns}"
  enable_dns_hostnames = "${var.enable_hostnames}"
  tags {
    Name = "${var.stack_item_label}-vpc"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
}

## Provisions Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.stack_item_label}-igw"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
}

## Provisions DMZ routing table
resource "aws_route_table" "rt_dmz" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags {
    Name = "${var.stack_item_label}-dmz"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
}

## Provisions NAT security group
resource "aws_security_group" "nat_sg" {
  name = "sg${var.stack_item_label}nat"
  description = "NAT security group"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name = "${var.stack_item_label}-nat"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
  ingress {
    cidr_blocks = ["${var.lan_cidr}"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
