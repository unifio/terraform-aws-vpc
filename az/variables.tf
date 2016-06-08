# Input variables

## Resource tags
variable "stack_item_label" {
  type        = "string"
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
}

variable "stack_item_fullname" {
  type        = "string"
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
}

## VPC parameters
variable "vpc_id" {
  type        = "string"
  description = "The ID of the VPC"
}

variable "region" {
  type        = "string"
  description = "The AWS region"
}

variable "az" {
  type        = "string"
  description = "Availability zone(s). Will accept a comma delimited string."
}

variable "dmz_cidr" {
  type        = "string"
  description = "The CIDR block(s) you want the DMZ subnet(s) to cover. Will accept a comma delimited string."
}

variable "lan_cidr" {
  type        = "string"
  description = "The CIDR block(s) you want the LAN subnet(s) to cover. Will accept a comma delimited string."
}

variable "lans_per_az" {
  type        = "string"
  description = "The number of private LAN subnets to be provisioned per AZ"
  default     = 1
}

variable "enable_dmz_public_ips" {
  type        = "string"
  description = "Specify true to indicate that instances launched into the DMZ subnet should be assigned a public IP address"
  default     = true
}

variable "rt_dmz_id" {
  type        = "string"
  description = "The ID of the DMZ routing table"
}

variable "rt_vgw_prop" {
  type        = "string"
  description = "Specifies whether virtual gateway route propagation should be enabled on the routing table(s)"
  default     = 0
}

variable "vgw_ids" {
  type        = "string"
  description = "A list of virtual gateways to associate with the routing tables for route propagation."
  default     = ""
}
