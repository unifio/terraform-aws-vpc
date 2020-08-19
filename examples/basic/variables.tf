# Input Variables

## Resource tags
variable "stack_item_fullname" {
  type = string
}

variable "stack_item_label" {
  type = string
}

## VPC base parameters
variable "enable_dns" {
  type    = bool

  //set true for test
  default = true
}

variable "enable_hostnames" {
  type    = bool
  //set false for test
  default = true
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
  //set for test
  default = "172.16.0.0/21"
}

## DHCP
variable "domain_name" {
  type    = string
  default = ""
}

## AZ parameters
variable "azs_provisioned" {
  type    = number
  default = 2
}

variable "enable_dmz_public_ips" {
  type    = bool
  //set false for testing
  default = true
}

variable "lans_per_az" {
  type    = number
  default = 1
}

variable "nat_eips_enabled" {
  type    = bool
  //set false for test
  default = true
}

## VPG parameters
variable "vpc_attach" {
  type    = bool
  default = true
}
