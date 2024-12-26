variable "content" {
  description = "JSON content of Terraform state or plan"
  type        = string
}
variable "enabled" {
  type = bool
  default = true
}
