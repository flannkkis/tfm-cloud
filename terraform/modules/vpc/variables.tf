variable "vpc_cidr" {
  description = "CIDR block de la VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs de subredes públicas"
  type        = list(string)
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs de subredes privadas de aplicación"
  type        = list(string)
}

variable "private_db_subnet_cidrs" {
  description = "CIDRs de subredes privadas de base de datos"
  type        = list(string)
}

variable "availability_zones" {
  description = "Zonas de disponibilidad"
  type        = list(string)
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
}

variable "environment" {
  description = "Entorno (dev, prepro, prod)"
  type        = string
}

variable "admin_ip" {
  description = "IP del administrador en formato CIDR (ej: 1.2.3.4/32)"
  type        = string
}
