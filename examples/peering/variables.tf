# Input Variables

## Resource Tags
variable "stack_item_label" {
  type        = "string"
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
}

variable "stack_item_fullname" {
  type        = "string"
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
}

## Peering Parameters
variable "region" {
  type        = "string"
  description = "The AWS region"
  default     = "us-west-2"
}

variable "peer_owner_id" {
  type        = "string"
  description = "The AWS account ID of the owner of the peer VPC."
}

variable "peer_rt_lan_id" {
  type        = "string"
  description = "The IDs of the peer VPC routing tables."
}

variable "peer_vpc_cidr" {
  type        = "string"
  description = "The ID of the peer VPC."
}

variable "peer_vpc_id" {
  type        = "string"
  description = "The ID of the VPC with which you are creating the VPC Peering Connection."
}

variable "owner_rt_lan_id" {
  type        = "string"
  description = "The IDs of the requesting VPC routing tables."
}

variable "owner_vpc_cidr" {
  type        = "string"
  description = "The ID of the requester VPC."
}

variable "owner_vpc_id" {
  type        = "string"
  description = "The ID of the requester VPC."
}
