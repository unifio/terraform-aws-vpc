# Output Variables

## Returns ID of the VPG
output "vpg_id" {
  value = "${coalesce(join(",",aws_vpn_gateway.vpg.*.id),join(",",aws_vpn_gateway.vpg_unattached.*.id))}"
}
