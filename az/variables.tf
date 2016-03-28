# Input variables

## Resource tags
variable "stack_item_label" {}
variable "stack_item_fullname" {}

## VPC parameters
variable "vpc_id" {}
variable "region" {}
variable "az" {}
variable "dmz_cidr" {}
variable "lan_cidr" {}
variable "enable_dmz_public_ips" {
  default = true
}
variable "lans_per_az" {
  default = 1
}
variable "rt_dmz_id" {}

}
}
}
}
}
