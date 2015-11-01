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
variable "enable_dmz_public_ips" {
  default = true
}
variable "dmz_cidr" {
  default = "10.10.0.0/25,10.10.0.128/25,10.10.1.0/25"
}
variable "lan_cidr" {
  default = "10.10.2.0/25,10.10.2.128/25,10.10.3.0/25"
}
variable "lans_per_az" {
  default = "1"
}
variable "enable_nat_eip" {
  default = "true"
}
variable "lan_access_cidr" {
  default = "10.10.2.0/23"
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

### NATs

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {}
variable "key_name" {}
variable "ssh_user" {}
variable "enable_nat_auto_recovery" {
  default = "true"
}
