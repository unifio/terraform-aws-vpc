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

## Peering parameters
variable "accepter_allow_remote_dns" {
  type        = "string"
  description = "Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC."
}

variable "multi_acct" {
  type        = "string"
  description = "Flag indicating whether the peering connection spans multiple AWS accounts"
  default     = "0"
}

variable "peer_owner_id" {
  type        = "string"
  description = "The AWS account ID of the owner of the peer VPC."
}

variable "peer_vpc_id" {
  type        = "string"
  description = "The ID of the VPC with which you are creating the VPC Peering Connection."
}

variable "requester_allow_remote_dns" {
  type        = "string"
  description = "Allow requester VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the accepter VPC."
}

variable "vpc_id" {
  type        = "string"
  description = "The ID of the requester VPC."
}
