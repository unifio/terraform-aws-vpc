# AWS VPC Peering Connection

## Configures AWS provider
provider "aws" {
  region = var.region
}

## Configures VPC peering connection
module "vpc_peer" {
  # Example GitHub source
  #source = "github.com/unifio/terraform-aws-vpc?ref=master//peer"
  source = "../../peer"

  accepter_allow_classic_link_to_remote  = "false"
  accepter_allow_remote_dns              = "true"
  accepter_allow_to_remote_classic_link  = "true"
  accepter_vpc_id                        = var.accepter_vpc_id
  requester_allow_classic_link_to_remote = "true"
  requester_allow_remote_dns             = "false"
  requester_allow_to_remote_classic_link = "false"
  requester_vpc_id                       = var.requester_vpc_id
  stack_item_fullname                    = var.stack_item_fullname
  stack_item_label                       = var.stack_item_label
}

resource "aws_route" "requester-to-accepter" {
  count = length(var.requester_rt_lan_ids)

  destination_cidr_block    = var.accepter_vpc_cidr
  route_table_id            = element(var.requester_rt_lan_ids, count.index)
  vpc_peering_connection_id = module.vpc_peer.peer_connection_id
}

resource "aws_route" "accepter-to-requester" {
  count = length(var.accepter_rt_lan_ids)

  destination_cidr_block    = var.requester_vpc_cidr
  route_table_id            = element(var.accepter_rt_lan_ids, count.index)
  vpc_peering_connection_id = module.vpc_peer.peer_connection_id
}

