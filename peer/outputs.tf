# Outputs

output "peer_connection_id" {
  value = "${join(",",aws_vpc_peering_connection.peer.*.id)}"
}
