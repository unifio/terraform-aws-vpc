# Input Variables

## Resource Tags
variable "stack_item_fullname" {
  type        = "string"
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
}

variable "stack_item_label" {
  type        = "string"
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
}

## Peering parameters
variable "accepter_allow_classic_link_to_remote" {
  type        = "string"
  description = "Allow a local linked EC2-Classic instance to communicate with instances in a peer VPC. This enables an outbound communication from the local ClassicLink connection to the remote VPC."
  default     = ""
}

variable "accepter_allow_remote_dns" {
  type        = "string"
  description = "Allow accepter VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the requester VPC."
  default     = "false"
}

variable "accepter_allow_to_remote_classic_link" {
  type        = "string"
  description = "Allow a local VPC to communicate with a linked EC2-Classic instance in a peer VPC. This enables an outbound communication from the local VPC to the remote ClassicLink connection."
  default     = ""
}

variable "accepter_auto_accept" {
  type        = "string"
  description = "Accept the peering (both VPCs need to be in the same AWS account)."
  default     = ""
}

variable "accepter_owner_id" {
  type        = "string"
  description = "The AWS account ID of the owner of the peer VPC."
  default     = ""
}

variable "accepter_vpc_id" {
  type        = "string"
  description = "The ID of the VPC with which you are creating the VPC Peering Connection."
  default     = ""
}

variable "requester_allow_classic_link_to_remote" {
  type        = "string"
  description = "Allow a local linked EC2-Classic instance to communicate with instances in a peer VPC. This enables an outbound communication from the local ClassicLink connection to the remote VPC."
  default     = ""
}

variable "requester_allow_remote_dns" {
  type        = "string"
  description = "Allow requester VPC to resolve public DNS hostnames to private IP addresses when queried from instances in the accepter VPC."
  default     = "false"
}

variable "requester_allow_to_remote_classic_link" {
  type        = "string"
  description = "Allow a local VPC to communicate with a linked EC2-Classic instance in a peer VPC. This enables an outbound communication from the local VPC to the remote ClassicLink connection."
  default     = ""
}

variable "requester_vpc_id" {
  type        = "string"
  description = "The ID of the requester VPC."
  default     = ""
}

variable "vpc_peering_connection_id" {
  type        = "string"
  description = "The VPC Peering Connection ID to manage."
  default     = ""
}
