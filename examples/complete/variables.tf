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
  type    = bool
  default = null
}

variable "enable_hostnames" {
  type    = bool
  default = null
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
  default = null
}

variable "region" {
  type = string
  //set for test
  //default = us-east-1
}

variable "vpc_cidr" {
  type = string
  //set for test
  //default = "172.16.0.0/21"
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
  type    = number
  default = null
  //set to 2 for test
  //default = 2
}

variable "ntp_servers" {
  type    = list(string)
  default = []
}
