# Peering Connection


locals {
  accepter_allow_classic_link_to_remote  = var.accepter_allow_classic_link_to_remote == "" ? null : tobool(var.accepter_allow_classic_link_to_remote)
  accepter_allow_remote_dns              = var.accepter_allow_remote_dns == "" ? null : tobool(var.accepter_allow_remote_dns)
  accepter_allow_to_remote_classic_link  = var.accepter_allow_to_remote_classic_link == "" ? null : tobool(var.accepter_allow_to_remote_classic_link)
  accepter_auto_accept                   = var.accepter_auto_accept == "" ? null : tobool(var.auto_accept)
  auto_accept                            = var.auto_accept == "" ? null : tobool(var.auto_accept)
  requester_allow_classic_link_to_remote = var.requester_allow_classic_link_to_remote == "" ? null : tobool(var.requester_allow_classic_link_to_remote)
  requester_allow_remote_dns             = var.requester_allow_remote_dns == "" ? null : tobool(var.requester_allow_remote_dns)
  requester_allow_to_remote_classic_link = var.requester_allow_to_remote_classic_link == "" ? null : tobool(var.requester_allow_to_remote_classic_link)
}
## Provisions VPC peering
resource "aws_vpc_peering_connection" "peer" {
  count = length(var.vpc_peering_connection_id) > 0 ? "0" : "1"

  auto_accept   = var.accepter_region != "" ? null : local.auto_accept
  peer_owner_id = var.accepter_owner_id
  peer_region   = var.accepter_region
  peer_vpc_id   = var.accepter_vpc_id
  vpc_id        = var.requester_vpc_id

  accepter {
    allow_classic_link_to_remote_vpc = local.accepter_allow_classic_link_to_remote
    allow_remote_vpc_dns_resolution  = local.accepter_allow_remote_dns
    allow_vpc_to_remote_classic_link = local.accepter_allow_to_remote_classic_link
  }

  requester {
    allow_classic_link_to_remote_vpc = local.requester_allow_classic_link_to_remote
    allow_remote_vpc_dns_resolution  = local.requester_allow_remote_dns
    allow_vpc_to_remote_classic_link = local.requester_allow_to_remote_classic_link
  }

  tags = {
    application = var.stack_item_fullname
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-peer"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer_accept" {
  count = length(var.vpc_peering_connection_id) > 0 ? "1" : "0"

  auto_accept               = local.accepter_auto_accept
  vpc_peering_connection_id = var.vpc_peering_connection_id

  accepter {
    allow_classic_link_to_remote_vpc = local.accepter_allow_classic_link_to_remote
    allow_remote_vpc_dns_resolution  = local.accepter_allow_remote_dns
    allow_vpc_to_remote_classic_link = local.accepter_allow_to_remote_classic_link
  }

  requester {
    allow_classic_link_to_remote_vpc = local.requester_allow_classic_link_to_remote
    allow_remote_vpc_dns_resolution  = local.requester_allow_remote_dns
    allow_vpc_to_remote_classic_link = local.requester_allow_to_remote_classic_link
  }

  tags = {
    application = var.stack_item_fullname
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-peer"
  }
}
