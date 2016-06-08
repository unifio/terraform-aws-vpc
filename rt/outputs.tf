# Outputs

output "rt_id" {
  value = "${coalesce(join(",",aws_route_table.rt.*.id),join(",",aws_route_table.rt_vgw_prop.*.id))}"
}
