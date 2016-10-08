# Virtual Private Gateway

# Gateway configuration
resource "aws_vpn_gateway" "vpg" {
  tags {
    Name        = "${var.stack_item_label}-vpg"
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
  }
}

resource "aws_vpn_gateway_attachment" "attach" {
  count = "${signum(var.vpc_attach)}"

  vpc_id         = "${var.vpc_id}"
  vpn_gateway_id = "${aws_vpn_gateway.vpg.id}"
}
