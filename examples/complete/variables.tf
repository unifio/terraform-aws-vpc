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
  type    = list
  default = ["a", "c", "d", "e"]
}

variable "enable_classiclink" {
  type    = bool
  default = false
}

variable "enable_hostnames" {
  type    = bool
  default = false
}

variable "instance_tenancy" {
  type    = string
  default = ""
}

variable "lans_per_az" {
  type    = number
  default = 1
}

variable "nat_gateways_enabled" {
  type    = bool
  default = true
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type = string
  default = "172.16.0.0/21"
}

## DHCP
variable "domain_name" {
  type    = string
  default = ""
}

variable "name_servers" {
  type    = list
  default = []
}

variable "netbios_name_servers" {
  type    = list
  default = []
}

variable "netbios_node_type" {
  type    = string
  default = ""
}

variable "ntp_servers" {
  type    = list
  default = []
}
