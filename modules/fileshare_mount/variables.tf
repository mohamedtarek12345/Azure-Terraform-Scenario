variable "vm_id" {
  description = "Map of Windows VM names to their IDs"
  type        = map(string)
}

variable "script_url" {
  description = "URL of the install-fileshare.sh script."
  type        = string
}

variable "storage_account_name" {
  description = "Storage account name for Azure File Share."
  type        = string
}

variable "storage_account_key" {
  description = "Storage account key for secure mounting."
  type        = string
}
variable "name" {
  description = "Name of the VM extension."
  type        = string
}