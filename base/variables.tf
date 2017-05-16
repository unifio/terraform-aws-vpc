# Input Variables

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
variable "enable_classiclink" {
  type        = "string"
  description = "A boolean flag to enable/disable ClassicLink for the VPC. Only valid in regions and accounts that support EC2 Classic. Defaults false."
  default     = ""
}

variable "enable_dns" {
  type        = "string"
  description = "A boolean flag to enable/disable DNS support in the VPC. Defaults true."
  default     = ""
}

variable "enable_hostnames" {
  type        = "string"
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Defaults false."
  default     = ""
}

variable "instance_tenancy" {
  type        = "string"
  description = "A tenancy option for instances launched into the VPC."
  default     = ""
}

variable "vpc_cidr" {
  type        = "string"
  description = "The CIDR block for the VPC."
  default     = "172.16.0.0/21"
}

## Flow log parameters
variable "flow_log_traffic_type" {
  type        = "string"
  description = "The type of traffic to capture. Valid values: ACCEPT,REJECT,ALL"
  default     = "ALL"
}

## Routing parameters
variable "vgw_ids" {
  type        = "list"
  description = "A list of virtual gateways for propagation."
  default     = []
}
