output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "app_private_ips" {
  value = aws_instance.app[*].private_ip
}

output "key_pair_name" {
  value = aws_key_pair.main.key_name
}
