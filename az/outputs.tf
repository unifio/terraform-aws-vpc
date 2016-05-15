# Output Variables

## Returns Subnet IDs
output "dmz_id" {
  value = "${join(",",aws_subnet.dmz.*.id)}"
}

output "lan_id" {
  value = "${join(",",aws_subnet.lan.*.id)}"
}

## Returns Subnet CIDR blocks
output "dmz_cidr" {
  value = "${join(",",aws_subnet.dmz.*.cidr_block)}"
}

output "lan_cidr" {
  value = "${join(",",aws_subnet.lan.*.cidr_block)}"
}

## Returns information about the NATs
output "eip_nat_id" {
  value = "${join(",",aws_eip.eip_nat.*.id)}"
}

output "nat_id" {
  value = "${join(",",aws_nat_gateway.nat.*.id)}"
}

## Returns the routing table ID
output "rt_lan_id" {
  value = "${join(",",aws_route_table.rt_lan.*.id)}"
}
