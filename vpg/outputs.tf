# Output Variables

## Returns ID of the VPG
output "vpg_id" {
  value = "${aws_vpn_gateway.vpg.id}"
}
