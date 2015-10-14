# Input Variables

## Resource Tags
variable "stack_item_label" {}
variable "stack_item_fullname" {}

## VPC parameters
variable "vpc_cidr" {}
variable "enable_dns" {
  default = true
}
variable "enable_hostnames" {
  default = true
}
variable "lan_cidr" {}
