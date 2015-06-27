# Input Variables

## Resource Tags
variable "app_label" {}
variable "app_name" {}

## VPC parameters
variable "vpc_cidr" {}
variable "enable_dns" {
        default = true
}
variable "enable_hostnames" {
        default = true
}
variable "lan_cidr" {}
