variable "project" { type = string }
variable "environment" { type = string }
variable "private_db_subnet_ids" { type = list(string) }
variable "sg_db_id" { type = string }
variable "db_name" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true  # No aparece en logs de Terraform
}
