# Output Variables

output "vpc_id" {
  value = "${module.vpc_base.vpc_id}"
}

output "dmz_subnet_ids" {
  value = "${module.vpc_az.dmz_id}"
}

output "lan_subnet_ids" {
  value = "${module.vpc_az.lan_id}"
}
