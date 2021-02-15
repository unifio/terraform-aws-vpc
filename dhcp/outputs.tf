# Output variables

output "dhcp_id" {
  value = join(",", compact(aws_vpc_dhcp_options.dhcp.*.id))
}

