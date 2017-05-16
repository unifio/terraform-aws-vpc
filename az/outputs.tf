# Output Variables

## Returns Subnet IDs
output "dmz_ids" {
  value = ["${aws_subnet.dmz.*.id}"]
}

output "lan_ids" {
  value = ["${aws_subnet.lan.*.id}"]
}

## Returns Subnet CIDR blocks
output "dmz_cidrs" {
  value = ["${aws_subnet.dmz.*.cidr_block}"]
}

output "lan_cidrs" {
  value = ["${aws_subnet.lan.*.cidr_block}"]
}

## Returns information about the NATs
output "eip_nat_ids" {
  value = ["${aws_eip.eip_nat.*.id}"]
}

output "eip_nat_ips" {
  value = ["${aws_eip.eip_nat.*.public_ip}"]
}

output "nat_ids" {
  value = ["${compact(concat(aws_instance.nat.*.id,aws_nat_gateway.nat.*.id))}"]
}

## Returns the routing table ID
output "rt_lan_ids" {
  value = ["${aws_route_table.rt_lan.*.id}"]
}
