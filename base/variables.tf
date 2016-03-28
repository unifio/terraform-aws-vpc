# Input Variables

## Resource Tags
variable "stack_item_label" {
  type = "string"
  description = "Short form identifier for this stack. This value is used to create the 'Name' resource tag for resources created by this stack item, and also serves as a unique key for re-use."
}
variable "stack_item_fullname" {
  type = "string"
  description = "Long form descriptive name for this stack item. This value is used to create the 'application' resource tag for resources created by this stack item."
}

## VPC parameters
variable "vpc_cidr" {
  type = "string"
  description = "The CIDR block you want the VPC to cover. For example: 10.0.0.0/16"
}
variable "instance_tenancy" {
  type = "string"
  description = "The allowed tenancy of instances launched into the VPC"
  default = "default"
}
variable "enable_dns" {
  type = "string"
  description = "Specifies whether DNS resolution is supported for the VPC"
  default = true
}
variable "enable_hostnames" {
  type = "string"
  description = "Specifies whether the instances launched in the VPC get DNS hostnames"
  default = true
}
variable "enable_classiclink" {
  type = "string"
  description = "Specifies whether ClassicLink is enabled for the VPC"
  default = false
}
variable "flow_log_traffic_type" {
  type = "string"
  description = "The type of traffic to capture. Valid values: ACCEPT,REJECT,ALL"
  default = "ALL"
}
