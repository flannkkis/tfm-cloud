variable "aws_region"              { type = string }
variable "project"                 { type = string }
variable "environment"             { type = string }
variable "vpc_cidr"                { type = string }
variable "public_subnet_cidrs"     { type = list(string) }
variable "private_app_subnet_cidrs"{ type = list(string) }
variable "private_db_subnet_cidrs" { type = list(string) }
variable "availability_zones"      { type = list(string) }
variable "admin_ip"                { type = string }
variable "public_key_path"         { type = string }
variable "app_instance_count"      {
type = number
default = 1
}
variable "db_name"                 { type = string }
variable "db_username"             { type = string }
variable "db_password"             {
type = string
sensitive = true
}
variable "alert_email"             { type = string }
