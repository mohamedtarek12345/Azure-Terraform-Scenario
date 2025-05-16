variable "vm_id" {
  description = "The ID of the VM to attach the extension to."
  type        = string
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