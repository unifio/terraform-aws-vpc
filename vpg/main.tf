# Virtual Private Gateway

# Gateway configuration
resource "aws_vpn_gateway" "vpg" {
  count  = "${signum(var.vpc_attach)}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name        = "${var.stack_item_label}-vpg"
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
  }
}

resource "aws_vpn_gateway" "vpg_unattached" {
  count = "${signum(var.vpc_attach) + 1 % 2}"

  tags {
    Name        = "${var.stack_item_label}-vpg"
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
  }
}
