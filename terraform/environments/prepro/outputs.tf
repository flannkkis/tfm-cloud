output "bastion_ip" {
  value       = module.ec2.bastion_public_ip
  description = "IP publica del bastion host"
}

output "db_endpoint" {
  value       = module.rds.db_endpoint
  description = "Endpoint de la base de datos"
}
