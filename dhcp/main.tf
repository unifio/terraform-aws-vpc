# DHCP Options

## Provisions DHCP options
resource "aws_vpc_dhcp_options" "dhcp" {
  domain_name          = "${var.domain_name}"
  domain_name_servers  = ["${split(",",var.name_servers)}"]
  ntp_servers          = ["${split(",",var.ntp_servers)}"]
  netbios_name_servers = ["${split(",",var.netbios_name_servers)}"]
  netbios_node_type    = "${var.netbios_node_type}"

  tags {
    Name        = "${var.stack_item_label}-dhcp"
    application = "${var.stack_item_fullname}"
    managed_by  = "terraform"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${var.vpc_id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp.id}"
}
