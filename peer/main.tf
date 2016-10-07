# Peering Connection

## Provisions VPC peering
resource "aws_vpc_peering_connection" "peer" {
  count         = "${signum(var.multi_acct) + 1 % 2}"
  auto_accept   = true
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id   = "${var.peer_vpc_id}"
  vpc_id        = "${var.vpc_id}"

  accepter {
    allow_remote_vpc_dns_resolution = "${var.accepter_allow_remote_dns}"
  }

  requester {
    allow_remote_vpc_dns_resolution = "${var.requester_allow_remote_dns}"
  }

  tags {
    Name        = "${var.stack_item_label}-peer"
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
  }
}

resource "aws_vpc_peering_connection" "peer_multi_acct" {
  count         = "${signum(var.multi_acct)}"
  peer_owner_id = "${var.peer_owner_id}"
  peer_vpc_id   = "${var.peer_vpc_id}"
  vpc_id        = "${var.vpc_id}"

  accepter {
    allow_remote_vpc_dns_resolution = "${var.accepter_allow_remote_dns}"
  }

  requester {
    allow_remote_vpc_dns_resolution = "${var.requester_allow_remote_dns}"
  }

  tags {
    Name        = "${var.stack_item_label}-peer"
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
  }
}
