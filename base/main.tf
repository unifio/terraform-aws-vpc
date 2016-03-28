# VPC Base

## Provisions Virtual Private Cloud (VPC)
resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_cidr}"
  instance_tenancy = "${var.instance_tenancy}"
  enable_dns_support = "${var.enable_dns}"
  enable_dns_hostnames = "${var.enable_hostnames}"
  enable_classiclink = "${var.enable_classiclink}"

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

  tags {
    Name = "${var.stack_item_label}-dmz"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
}

## Provision VPC flow log
resource "aws_cloudwatch_log_group" "flow_log_group" {
  name = "${var.stack_item_label}-vpc-flow-logs"
}

resource "aws_iam_role" "flow_log_role" {
    name = "${var.stack_item_label}-vpc-flow-logs"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow_log_role_policies" {
    name = "flow-logs"
    role = "${aws_iam_role.flow_log_role.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_flow_log" "flow_log" {
  log_group_name = "${var.stack_item_label}-vpc-flow-logs"
  iam_role_arn = "${aws_iam_role.flow_log_role.arn}"
  vpc_id = "${aws_vpc.vpc.id}"
  traffic_type = "ALL"
}
