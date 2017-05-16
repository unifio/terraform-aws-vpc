# Input variables

## Resource tags
variable "stack_item_fullname" {
  type        = "string"
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
  default     = "VPC Quick Start"
}

variable "stack_item_label" {
  type        = "string"
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
  default     = "qckstrt"
}

## VPC parameters
variable "az_cidrsubnet_newbits" {
  type        = "map"
  description = "The number of bits by which to extend the CIDR range for the given number of AZs."

  default = {
    "1" = "1"
    "2" = "2"
    "3" = "3"
    "4" = "3"
    "6" = "4"
    "8" = "4"
  }
}

variable "az_cidrsubnet_offset" {
  type        = "map"
  description = "The number of AZs to provision for."

  default = {
    "1" = "1"
    "2" = "2"
    "3" = "4"
    "4" = "4"
  }
}

variable "azs_provisioned" {
  type        = "string"
  description = "The number of availability zones to be provisioned."
  default     = "2"
}

variable "azs_provisioned_override" {
  type        = "list"
  description = "List of availability zones to be provisioned."
  default     = ["non_empty_list"]
}

variable "dmz_cidrs" {
  type        = "list"
  description = "The CIDR block(s) you want the DMZ subnet(s) to cover."
  default     = ["non_empty_list"]
}

variable "enable_dmz_public_ips" {
  type        = "string"
  description = "Specify true to indicate that instances launched into the DMZ subnet should be assigned a public IP address. Default is false."
  default     = ""
}

variable "lan_cidrs" {
  type        = "list"
  description = "The CIDR block(s) you want the LAN subnet(s) to cover."
  default     = ["non_empty_list"]
}

variable "lans_per_az" {
  type        = "string"
  description = "The number of private LAN subnets to be provisioned per AZ"
  default     = "1"
}

variable "nat_ami_override" {
  type        = "string"
  description = "Custom NAT Amazon machine image"
  default     = ""
}

variable "nat_eips_enabled" {
  type        = "string"
  description = "Flag for specifying allocation of Elastic IPs to NATs for the purposes of whitelisting. This value is overriden to 'true' when utilizing NAT gateways."
  default     = "false"
}

variable "nat_gateways_enabled" {
  type        = "string"
  description = "Flag for specifying utilization of managed NAT gateways over EC2 based NAT instances."
  default     = "false"
}

variable "nat_instance_type" {
  type        = "string"
  description = "NAT EC2 instance type"
  default     = "t2.nano"
}

variable "nat_key_name" {
  type        = "string"
  description = "NAT EC2 key pair name"
  default     = ""
}

variable "rt_dmz_id" {
  type        = "string"
  description = "The ID of the DMZ routing table"
}

variable "vgw_ids" {
  type        = "list"
  description = "A list of virtual gateways to associate with the routing tables for route propagation."
  default     = []
}

variable "vpc_id" {
  type        = "string"
  description = "The ID of the VPC"
}
