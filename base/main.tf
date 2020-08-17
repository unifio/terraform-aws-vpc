# VPC base

## Set Terraform version constraint
terraform {
  required_version = "> 0.11.0"
}

## Set default instance tennancy if not provided
locals {
  default_instance_tenancy = "${length(var.instance_tenancy) >= 1 ? "${var.instance_tenancy}" : "default"}"

  default_vpc_tags = {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-vpc"
  }
}

## Provisions Virtual Private Cloud (VPC)
resource "aws_vpc" "vpc" {
  cidr_block                       = "${var.vpc_cidr}"
  instance_tenancy                 = "${local.default_instance_tenancy}"
  enable_dns_support               = "${var.enable_dns}"
  enable_dns_hostnames             = "${var.enable_hostnames}"
  enable_classiclink               = "${var.enable_classiclink}"
  enable_classiclink_dns_support   = "${var.enable_classiclink_dns_support}"
  assign_generated_ipv6_cidr_block = "${var.assign_generated_ipv6_cidr_block}"

  tags = "${merge(local.default_vpc_tags, var.additional_vpc_tags)}"
}

## Provisions Internet gateways
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-igw"
  }
}

## Provisions DMZ routing table
resource "aws_route_table" "rt_dmz" {
  propagating_vgws = ["${compact(var.vgw_ids)}"]
  vpc_id           = "${aws_vpc.vpc.id}"

  tags = {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-dmz"
  }
}

## Provisions VPC flow logs
resource "aws_cloudwatch_log_group" "flow_log_group" {
  name_prefix = "${var.stack_item_label}-vpc-logs-"
}

data "aws_iam_policy_document" "flow_log_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "flow_log_role" {
  assume_role_policy = "${data.aws_iam_policy_document.flow_log_role.json}"
  name_prefix        = "${var.stack_item_label}-vpc-logs-"
}

data "aws_iam_policy_document" "flow_log_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["${aws_cloudwatch_log_group.flow_log_group.arn}"]
  }
}

resource "aws_iam_role_policy" "flow_log_role_policies" {
  name   = "logs"
  policy = "${data.aws_iam_policy_document.flow_log_policy.json}"
  role   = "${aws_iam_role.flow_log_role.id}"
}

resource "aws_flow_log" "flow_log" {
  log_destination = "${aws_cloudwatch_log_group.flow_log_group.arn}"
  iam_role_arn    = "${aws_iam_role.flow_log_role.arn}"
  vpc_id          = "${aws_vpc.vpc.id}"
  traffic_type    = "${var.flow_log_traffic_type}"
}
