# Output Variables

## Returns ID of the VPC
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

## Returns ID of the Internet gateway
output "igw_id" {
  value = "${aws_internet_gateway.igw.id}"
}

## Returns ID of the DMZ routing table
output "rt_dmz_id" {
  value = "${aws_route_table.rt_dmz.id}"
}

output "flow_log_id" {
  value = "${aws_flow_log.flow_log.id}"
}
