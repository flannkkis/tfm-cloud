output "bastion_ip" {
  value       = module.ec2.bastion_public_ip
  description = "IP publica del bastion host"
}

output "db_endpoint" {
  value       = module.rds.db_endpoint
  description = "Endpoint de la base de datos"
}

output "app_private_ips" {
  value       = module.ec2.app_private_ips
  description = "IPs privadas de los servidores de aplicacion"
}
