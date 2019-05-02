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
  type    = string
  default = ""
}

variable "enable_hostnames" {
  type    = string
  default = ""
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

## DHCP
variable "domain_name" {
  type    = string
  default = ""
}

## AZ parameters
variable "azs_provisioned" {
  type    = string
  default = ""
}

variable "enable_dmz_public_ips" {
  type    = string
  default = ""
}

variable "lans_per_az" {
  type    = string
  default = "1"
}

variable "nat_eips_enabled" {
  type    = string
  default = ""
}

## VPG parameters
variable "vpc_attach" {
  type    = string
  default = ""
}

