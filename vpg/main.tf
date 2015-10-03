# Virtual Private Gateway

# Gateway configuration
resource "aws_vpn_gateway" "vpg" {
        vpc_id = "${var.vpc_id}"
        tags {
                Name = "${var.app_label}-vpg"
                application = "${var.app_name}"
                managed_by = "terraform"
        }
}
