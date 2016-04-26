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

## VPC Parameters
variable "region" {
  type        = "string"
  description = "The AWS region"
  default     = "us-west-2"
}

variable "vpc_cidr" {
  type        = "string"
  description = "The CIDR block you want the VPC to cover. For example: 10.0.0.0/16"
  default     = "10.10.0.0/22"
}

variable "az" {
  type        = "map"
  description = "The AWS availability zone"

  default = {
    us-west-2 = "a,b,c"
  }
}

variable "lans_per_az" {
  type        = "string"
  description = "The number of private LAN subnets to be provisioned per AZ"
  default     = 1
}

variable "enable_dmz_public_ips" {
  type        = "string"
  description = "Specify true to indicate that instances launched into the DMZ subnet should be assigned a public IP address"
  default     = false
}

variable "enable_dns" {
  type        = "string"
  description = "Specifies whether DNS resolution is supported for the VPC"
  default     = false
}

variable "enable_hostnames" {
  type        = "string"
  description = "Specifies whether the instances launched in the VPC get DNS hostnames"
  default     = false
}
