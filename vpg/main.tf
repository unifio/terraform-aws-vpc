# Virtual Private Gateway

# Gateway configuration
resource "aws_vpn_gateway" "vpg" {
  vpc_id = "${var.vpc_id}"
  tags {
    Name = "${var.stack_item_label}-vpg"
    application = "${var.stack_item_fullname}"
    managed_by = "terraform"
  }
}
