# Input Variables

## Resource Tags

variable "stack_item_label" {}
variable "stack_item_fullname" {}

## VPC Parameters

### Networking

variable "region" {
  default = "us-west-2"
}
variable "vpc_cidr" {
  default = "10.10.0.0/22"
}
variable "az" {
  default = {
    us-west-2 = "a,b,c"
  }
}
variable "lans_per_az" {
  default = 1
}
}
### DHCP

variable "enable_dns" {
  default = true
}
variable "enable_hostnames" {
  default = true
}
variable "netbios_node_type" {
  default = 2
}
variable "domain_name" {}
variable "name_servers" {
  default = "127.0.0.1,10.10.0.2,10.10.1.2"
}
variable "ntp_servers" {
  default = "127.0.0.1"
}
variable "netbios_name_servers" {
  default = "127.0.0.1"
}
}
