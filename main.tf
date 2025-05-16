# main.tf
# this is the main file for the Terraform configuration
# it includes the module calls

module "rg" {
  source   = "./modules/resource_group"
  name     = var.resource_group_name
  location = var.location
}



module "vnet" {
  source              = "./modules/vnet"
  for_each            = var.vnets
  vnet_name           = each.key 
  address_space       = each.value.address_space
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

}

module "subnet" {
  source              = "./modules/subnet"
  for_each            = var.subnets
  subnet_name         = each.key
  resource_group_name = each.value.resource_group_name
  vnet_name           = module.vnet[each.value.vnet_key].vnet_name
  address_prefixes    = each.value.address_prefixes
}

module "vnet_peerings" {
  source = "./modules/vnet_peering"
  for_each = {
    "hub-to-spoke" = {
      vnet_name      = module.vnet["HubVNet"].vnet_name
      remote_vnet_id = module.vnet["SpokeVNet"].vnet_id
    }
    "spoke-to-hub" = {
      vnet_name      = module.vnet["SpokeVNet"].vnet_name
      remote_vnet_id = module.vnet["HubVNet"].vnet_id
    }
  }

  name                      = each.key
  resource_group_name       = module.rg.name
  virtual_network_name      = each.value.vnet_name
  remote_virtual_network_id = each.value.remote_vnet_id
}

module "vms" {
  source = "./modules/vm"

  for_each = {
    "win-vm-1" = {
      subnet_key          = "PLB_sub"
      os_type             = "Windows"
      availability_zone   = 2
      create_public_ip    = true
      backend_pool_id     = [module.load_balancers["windows-public-lb"].backend_pool_id]
      custom_message      = "Hello Website 1"
    }
    "win-vm-2" = {
      subnet_key          = "PLB_sub"
      os_type             = "Windows"
      availability_zone   = 1
      create_public_ip    = false
      backend_pool_id     = [module.load_balancers["windows-public-lb"].backend_pool_id]
      custom_message      = "Hello Website 2"
    }
    "linux-vm-1" = {
      subnet_key         = "ILB_sub"
      os_type            = "Linux"
      availability_zone  = 2
      create_public_ip   = true
      backend_pool_id = [module.load_balancers["linux-private-lb"].backend_pool_id]
      custom_message2    = "Hello from Apache 1"
    }
    "linux-vm-2" = {
      subnet_key         = "ILB_sub"
      os_type            = "Linux"
      availability_zone  = 1
      create_public_ip   = true
      backend_pool_id = [module.load_balancers["linux-private-lb"].backend_pool_id]
      custom_message2    = "Hello from Apache 2"
    }
  }

  name                  = each.key
  location              = var.location
  resource_group_name   = module.rg.name
  subnet_id             = module.subnet[each.value.subnet_key].subnet_id
  vm_size               = "Standard_D2as_v5"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  os_type               = each.value.os_type
  availability_zone     = each.value.availability_zone
  create_public_ip      = each.value.create_public_ip
  backend_pool_ids      = each.value.backend_pool_id
  storage_account_name  = module.storage.storage_account_name
  storage_account_key   = module.storage.primary_access_key
  fileshare_name        = module.storage.fileshare_name
}

module "load_balancers" {
  source = "./modules/lb"

  for_each = {
    "windows-public-lb" = {
      lb_type     = "public"
      subnet_key  = null
      lb_port     = 80
      probe_port  = 80
    },
    "linux-private-lb" = {
      lb_type     = "private"
      subnet_key  = "ILB_sub"
      lb_port     = 80
      probe_port  = 80
    }
  }

  name                = each.key
  location            = var.location
  resource_group_name = module.rg.name
  lb_type             = each.value.lb_type
  subnet_id           = each.value.lb_type == "private" ? module.subnet[each.value.subnet_key].subnet_id : null
  lb_port             = each.value.lb_port
  lb_probe_port       = each.value.probe_port
}

resource "random_integer" "rand" {
  min = 1000
  max = 9999
}

module "storage" {
  source               = "./modules/storage_account"
  storage_account_name = "premiumshare${random_integer.rand.result}"
  resource_group_name  = module.rg.name
  location             = var.location
  fileshare_name       = "appfiles"
}

module "private_dns_zone" {
  source              = "./modules/dns"
  zone_name           = "privatelink.database.windows.net"
  resource_group_name = module.rg.name
  vnet_id             = module.vnet["HubVNet"].vnet_id
  name_prefix         = "sql"
}

module "private_endpoint" {
  source                = "./modules/private_endpoint"
  name_prefix           = "sql"
  location              = var.location
  resource_group_name   = module.rg.name
  subnet_id             = module.subnet["DNS_SQL_private_endpoints_sub"].subnet_id
  sql_server_id         = module.sql_database.sql_server_id
  private_dns_zone_id   = module.private_dns_zone.private_dns_zone_id
}

module "sql_database" {
  source              = "./modules/sql_database"
  name_prefix         = "myapp-sqlserver"
  location            = var.location
  resource_group_name = module.rg.name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
}

module "fileshare_mount" {
  source                = "./modules/fileshare_mount"
  vm_id                 = module.vms["linux-vm-1"]["linux-vm-2"].vm_ids
  script_url            = "https://raw.githubusercontent.com/mohamedtarek12345/Azure-Terraform-Scenario/main/modules/fileshar_mount/scripts/install-fileshare.sh"
  storage_account_name  = module.storage.storage_account_name
  storage_account_key   = module.storage.primary_access_key
  name                  = "appfiles"
  os_type               = "linux"
}


