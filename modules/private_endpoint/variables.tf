variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint"
}

variable "sql_server_id" {
  type        = string
  description = "Azure SQL Server resource ID"
}

variable "private_dns_zone_id" {
  type        = string
  description = "ID of the private DNS zone"
}
