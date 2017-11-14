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

## VPC parameters
variable "vpc_id" {
  type        = "string"
  description = "The ID of the VPC"
}

## DHCP parameters
variable "domain_name" {
  type        = "string"
  description = "The suffix domain name to use by default when resolving non Fully Qualified Domain Names"
  default     = ""
}

variable "enable" {
  type        = "string"
  description = "Determine if resources should be added.  Used if you want to include conditionally in a module."
  default     = "true"
}

variable "name_servers" {
  type        = "list"
  description = "List of name servers to configure in '/etc/resolv.conf'"
  default     = ["AmazonProvidedDNS"]
}

variable "netbios_name_servers" {
  type        = "list"
  description = "List of NETBIOS name servers"
  default     = []
}

variable "netbios_node_type" {
  type        = "string"
  description = "The NetBIOS node type (1, 2, 4, or 8). AWS recommends to specify 2 since broadcast and multicast are not supported in their network."
  default     = ""
}

variable "ntp_servers" {
  type        = "list"
  description = "List of NTP servers to configure"
  default     = []
}
