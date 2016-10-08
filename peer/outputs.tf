# Outputs

output "peer_connection_id" {
  value = "${coalesce(join(",",aws_vpc_peering_connection.peer.*.id),join(",",aws_vpc_peering_connection.peer_multi_acct.*.id))}"
}
