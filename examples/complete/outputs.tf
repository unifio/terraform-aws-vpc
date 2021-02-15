# Output variables

output "dmz_subnet_ids" {
  value = module.vpc_az.dmz_ids
}

output "lan_rt_ids" {
  value = module.vpc_az.rt_lan_ids
}

output "lan_subnet_ids" {
  value = module.vpc_az.lan_ids
}

output "vpc_id" {
  value = module.vpc_base.vpc_id
}

