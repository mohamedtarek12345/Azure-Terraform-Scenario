variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "subnet_id" {}
variable "vm_size" {}
variable "admin_username" {}
variable "admin_password" {}
variable "availability_zone" {}
variable "create_public_ip" {
  type    = bool
  default = false
}
variable "backend_pool_ids" {
  type    = list(string)
  default = []
}

variable "os_type" {
  description = "The operating system type (Windows/Linux)"
  type        = string
}



variable "custom_message" {
  description = "The message to display on the IIS homepage"
  type        = string
  default     = "Hello from IIS"
}

variable "custom_message2" {
  description = "The message to display on the Nginx homepage"
  type        = string
  default     = "Hello from Apache"
}

variable "storage_account_name" {
  type        = string
  description = "Name of the Azure Storage Account"
}

variable "storage_account_key" {
  type        = string
  description = "Storage account access key"
}

variable "fileshare_name" {
  type        = string
  description = "Name of the Azure File Share"
}



