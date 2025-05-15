######## VNet Outputs #######
output "vnet_name" {
  description = "VNet names"
  value = {
    for vnet_key, vnet_mod in module.vnet :
    vnet_key => vnet_mod.vnet_name
  }
}

output "vnet_id" {
  description = "VNet resource IDs"
  value = {
    for vnet_key, vnet_mod in module.vnet :
    vnet_key => vnet_mod.vnet_id
  }
}
output "vnet_address_space" {
  description = "VNet address spaces"
  value = {
    for vnet_key, vnet_mod in module.vnet :
    vnet_key => vnet_mod.vnet_address_space
  }
}
output "vnet_location" {
  description = "VNet locations"
  value = {
    for vnet_key, vnet_mod in module.vnet :
    vnet_key => vnet_mod.vnet_location
  }
}
######### Subnet Outputs #######
output "subnet_names" {
  value = {
    for subnet_key, subnet_mod in module.subnet :
    subnet_key => subnet_mod.subnet_name
  }
}

output "subnet_ids" {
  value = {
    for subnet_key, subnet_mod in module.subnet :
    subnet_key => subnet_mod.subnet_id
  }
}

output "subnet_address_prefixes" {
  value = {
    for subnet_key, subnet_mod in module.subnet :
    subnet_key => subnet_mod.sub_add_prf
  }
}

output "subnet_resource_group_names" {
  value = {
    for subnet_key, subnet_mod in module.subnet :
    subnet_key => subnet_mod.sub_rg_name
  }
}

output "subnet_vnet_names" {
  value = {
    for subnet_key, subnet_mod in module.subnet :
    subnet_key => subnet_mod.sub_vnet_name
  }
}
