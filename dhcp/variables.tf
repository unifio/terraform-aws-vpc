# Input Variables

## Resource Tags
variable "app_label" {}
variable "app_name" {}

## VPC parameters
variable "vpc_id" {}
variable "domain_name" {}
variable "name_servers" {}
variable "ntp_servers" {}
variable "netbios_name_servers" {}
variable "netbios_node_type" {
        default = 2
}
