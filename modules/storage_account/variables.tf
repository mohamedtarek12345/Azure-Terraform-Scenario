variable "storage_account_name" {
  type = string
}

variable "fileshare_name" {
  type = string

}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "share_quota_gb" {
  type    = number
  default = 100
}

variable "tags" {
  type    = map(string)
  default = {}
}
