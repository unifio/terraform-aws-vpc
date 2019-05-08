# Output Variables

## Returns information about dmz subnets
output "dmz_ids" {
  value = ["${aws_subnet.dmz.*.id}"]
}

output "dmz_cidrs" {
  value = ["${aws_subnet.dmz.*.cidr_block}"]
}


## Returns information about lan subnets
output "lan_ids" {
  value = ["${aws_subnet.lan.*.id}"]
}

output "lan_cidrs" {
  value = ["${aws_subnet.lan.*.cidr_block}"]
}

output "rt_lan_ids" {
  value = ["${aws_route_table.rt_lan.*.id}"]
}


## Returns information about static subnets
output "static_ids" {
  value = ["${aws_subnet.static.*.id}"]
}

output "static_cidrs" {
  value = ["${aws_subnet.static.*.cidr_block}"]
}

output "rt_static_ids" {
  value = ["${aws_route_table.rt_static.*.id}"]
}


## Returns information about the NATs
output "eip_nat_ids" {
  value = ["${aws_eip.eip_nat.*.id}"]
}

output "eip_nat_ips" {
  value = ["${aws_eip.eip_nat.*.public_ip}"]
}

output "nat_ids" {
  value = ["${compact(concat(aws_instance.nat.*.id, aws_nat_gateway.nat.*.id))}"]
}

