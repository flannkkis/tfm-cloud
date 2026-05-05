variable "project" { type = string }
variable "environment" { type = string }
variable "public_key_path" { type = string }
variable "public_subnet_id" { type = string }
variable "private_app_subnet_ids" { type = list(string) }
variable "sg_bastion_id" { type = string }
variable "sg_app_id" { type = string }
variable "app_instance_count" {
	type = number
	default = 1
}
variable "app_instance_profile" { type = string }
