# Output Variables

## Returns Subnet IDs
output "dmz_id" {
  value = "${join(",",aws_subnet.dmz.*.id)}"
}

output "lan_id" {
  value = "${join(",",aws_subnet.lan.*.id)}"
}

## Returns information about the NATs
output "eip_nat_id" {
  value = "${join(",",aws_eip.eip_nat.*.id)}"
}

output "nat_id" {
  value = "${join(",",aws_nat_gateway.nat.*.id)}"
}

