# Output variables

output "dhcp_id" {
  value = "${aws_vpc_dhcp_options.dhcp.id}"
}
