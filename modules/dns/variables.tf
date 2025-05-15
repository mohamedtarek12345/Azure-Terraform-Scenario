variable "zone_name" {
  type        = string
  description = "Name of the private DNS zone"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "vnet_id" {
  type        = string
  description = "Hub VNet ID to link"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
}
