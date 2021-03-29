# Output Variables

output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "rt_dmz_id" {
  value = aws_route_table.rt_dmz.id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_default_security_group_id" {
  value = aws_vpc.vpc.default_security_group_id
}

