# Virtual Private Gateway

## Set Terraform version constraint
terraform {
  required_version = "> 0.11.0"
}

## Gateway configuration
resource "aws_vpn_gateway" "vpg" {
  availability_zone = var.availability_zone

  tags = {
    application = var.stack_item_fullname
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-vpg"
  }
}

resource "aws_vpn_gateway_attachment" "attach" {
  count = var.vpc_attach ? 1 : 0

  vpc_id         = var.vpc_id
  vpn_gateway_id = aws_vpn_gateway.vpg.id
}
