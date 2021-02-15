# Input Variables

## Resource Tags
variable "stack_item_fullname" {
  type = string
}

variable "stack_item_label" {
  type = string
}

## VPC Parameters
variable "azs_provisioned_override" {
  type    = list(string)
  default = ["a", "c", "d", "e"]
}

variable "enable_classiclink" {
  type    = string
  default = ""
}

variable "enable_hostnames" {
  type    = string
  default = ""
}

variable "instance_tenancy" {
  type    = string
  default = ""
}

variable "lans_per_az" {
  type    = string
  default = ""
}

variable "nat_gateways_enabled" {
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

variable "name_servers" {
  type    = list(string)
  default = []
}

variable "netbios_name_servers" {
  type    = list(string)
  default = []
}

variable "netbios_node_type" {
  type    = string
  default = ""
}

variable "ntp_servers" {
  type    = list(string)
  default = []
}

