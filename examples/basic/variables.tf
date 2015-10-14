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
variable "lan_access_cidr" {
  default = "10.10.2.0/23"
}

### NATs

variable "instance_type" {
  default = "t2.micro"
}
variable "user_data_template" {
  default = "user_data.tpl"
}
variable "ami" {}
variable "key_name" {}
variable "ssh_user" {}
