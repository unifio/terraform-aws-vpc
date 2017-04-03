# Input Variables

## Resource tags
variable "stack_item_fullname" {
  type        = "string"
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
}

variable "stack_item_label" {
  type        = "string"
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
}

## VPC parameters
variable "availability_zone" {
  type        = "string"
  description = "The Availability Zone for the virtual private gateway."
  default     = ""
}

variable "vpc_attach" {
  type        = "string"
  description = "Specifies whether the VPG should be associated with a VPC."
  default     = ""
}

variable "vpc_id" {
  type        = "string"
  description = "The VPC ID to create in."
  default     = ""
}
