# Output Variables

## Returns ID of the DHCP options resource
output "dhcp_id" {
        value = "${aws_vpc_dhcp_options.dhcp.id}"
}
