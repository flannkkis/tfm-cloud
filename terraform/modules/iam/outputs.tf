output "app_instance_profile_name" {
  value = aws_iam_instance_profile.app_profile.name
}

output "app_role_arn" {
  value = aws_iam_role.app_role.arn
}
