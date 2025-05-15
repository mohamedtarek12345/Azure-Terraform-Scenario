variable "client_id" {}             
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

variable "resource_group_name" {
  default = "Terraform-RG"
}

variable "location" {
  default = "Central India"
}


variable "vnets" {
  description = "The virtual networks to create"
  # The key is the name of the VNet, and the value is an object with properties
  type = map(object({

    address_space       = list(string)
    location            = string
    resource_group_name = string
  }))
  
  default = {
    "HubVNet" = {
        address_space = ["10.0.0.0/16"]
        location      = "Central India"
        resource_group_name = "Terraform-RG"
    },
    "SpokeVNet" = {
        address_space = ["10.1.0.0/16"]
        location      = "Central India"
        resource_group_name = "Terraform-RG"
    }
  }
}

variable "subnets" {

  type = map(object({
    address_prefixes     = list(string)
    vnet_key            = string
    resource_group_name  = string
  }))

  default = {
    "PLB_sub" = {
    resource_group_name  = "Terraform-RG"
    address_prefixes     = ["10.0.1.0/24"]
    vnet_key            = "HubVNet"
    },
    "ILB_sub" = {
    resource_group_name  = "Terraform-RG"
    address_prefixes     = ["10.0.2.0/24"]
    vnet_key            = "HubVNet"
    },
    "DNS_SQL_private_endpoints_sub" = {
    resource_group_name  = "Terraform-RG"
    address_prefixes     = ["10.1.0.0/24"]
    vnet_key            = "SpokeVNet"
    }
  }
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VMs"
}

variable "admin_password" {
  type        = string
  description = "Admin password for the VMs"
  sensitive   = true
}

variable "create_public_ip" {
  type    = bool
  default = false
}
