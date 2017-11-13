# DHCP Options

## Set Terraform version constraint
terraform {
  required_version = "> 0.8.0"
}

## Provisions DHCP options
resource "aws_vpc_dhcp_options" "dhcp" {
  count = "${var.enable == "true" ? "1" : "0"}"

  domain_name          = "${var.domain_name}"
  domain_name_servers  = ["${compact(var.name_servers)}"]
  netbios_name_servers = ["${compact(var.netbios_name_servers)}"]
  netbios_node_type    = "${var.netbios_node_type}"
  ntp_servers          = ["${compact(var.ntp_servers)}"]

  tags {
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
    Name        = "${var.stack_item_label}-dhcp"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  count = "${var.enable == "true" ? "1" : "0"}"

  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp.id}"
  vpc_id          = "${var.vpc_id}"
}
