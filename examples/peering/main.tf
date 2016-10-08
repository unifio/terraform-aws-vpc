# AWS VPC Peering Connection

## Configures AWS provider
provider "aws" {
  region = "${var.region}"
}

## Configures VPC peering connection
module "vpc_peer" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//peer"
  source = "../../peer"

  stack_item_label           = "${var.stack_item_label}"
  stack_item_fullname        = "${var.stack_item_fullname}"
  accepter_allow_remote_dns  = "false"
  peer_owner_id              = "${var.peer_owner_id}"
  peer_vpc_id                = "${var.peer_vpc_id}"
  requester_allow_remote_dns = "true"
  vpc_id                     = "${var.owner_vpc_id}"
}

resource "aws_route" "owner-to-peer" {
  route_table_id             = "${element(split(",",var.owner_rt_lan_id),count.index)}"
  destination_cidr_block     = "${var.peer_vpc_cidr}"
  vpc_peering_connection_id  = "${module.vpc_peer.peer_connection_id}"
}

resource "aws_route" "peer-to-owner" {
  route_table_id             = "${element(split(",",var.peer_rt_lan_id),count.index)}"
  destination_cidr_block     = "${var.owner_vpc_cidr}"
  vpc_peering_connection_id  = "${module.vpc_peer.peer_connection_id}"
}
