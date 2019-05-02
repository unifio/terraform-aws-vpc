# Input Variables

## Resource Tags
variable "stack_item_fullname" {
  type        = string
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
}

variable "stack_item_label" {
  type        = string
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
}

## Peering Parameters
variable "accepter_rt_lan_ids" {
  type        = list(string)
  description = "The IDs of the peer VPC routing tables."
}

variable "accepter_vpc_cidr" {
  type        = string
  description = "The ID of the peer VPC."
}

variable "accepter_vpc_id" {
  type        = string
  description = "The ID of the VPC with which you are creating the VPC Peering Connection."
}

variable "region" {
  type = string
}

variable "requester_rt_lan_ids" {
  type        = list(string)
  description = "The IDs of the requesting VPC routing tables."
}

variable "requester_vpc_cidr" {
  type        = string
  description = "The ID of the requester VPC."
}

variable "requester_vpc_id" {
  type        = string
  description = "The ID of the requester VPC."
}

