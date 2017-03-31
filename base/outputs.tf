# Output Variables

output "flow_log_id" {
  value = "${aws_flow_log.flow_log.id}"
}

output "igw_id" {
  value = "${aws_internet_gateway.igw.id}"
}

output "rt_dmz_id" {
  value = "${aws_route_table.rt_dmz.id}"
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}
