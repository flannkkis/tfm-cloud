# Rol para las instancias EC2 (permite a las VMs hablar con CloudWatch y SSM)
resource "aws_iam_role" "app_role" {
  name = "${var.project}-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# Adjuntar política de CloudWatch (para enviar logs y métricas)
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Adjuntar política de SSM (para gestión sin SSH directo si se prefiere)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Perfil de instancia — es el "envoltorio" que une el rol con la instancia EC2
resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.project}-app-profile"
  role = aws_iam_role.app_role.name
}

# Política de contraseñas robusta para usuarios IAM
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 12
  hard_expiry                    = false
}
