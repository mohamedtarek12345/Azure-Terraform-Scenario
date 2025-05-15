variable "name" {}
variable "location" {}
variable "resource_group_name" {}
variable "lb_type" {} # "public" or "private"
variable "subnet_id" {
  default = null
}
variable "lb_port" {
  default = 80
}
variable "lb_probe_port" {
  default = 80
}
