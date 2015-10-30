# Input variables

## Resource tags
variable "stack_item_label" {}
variable "stack_item_fullname" {}

## VPC parameters
variable "vpc_id" {}
variable "region" {}
variable "az" {}
variable "dmz_cidr" {}
variable "lan_cidr" {}
variable "enable_dmz_public_ips" {
  default = true
}
variable "lans_per_az" {
  default = 1
}
variable "rt_dmz_id" {}

## NAT parameters
variable "ami" {}
variable "instance_type" {}
variable "key_name" {}
variable "nat_sg_id" {}
variable "enable_nats" {
  default = "true"
}
variable "enable_nat_auto_recovery" {
  default = "true"
}
variable "period" {
  default = 60
}
variable "evaluation_periods" {
  default = 2
}

## Context parameters
variable "user_data_template" {
  default = "user_data.tpl"
}
variable "domain" {}
variable "ssh_user" {
  default = "ec2-user"
}

# Internal variables
variable "decision_tree" {
  default = {
    "false" = 0
    "true" = 1
  }
}
