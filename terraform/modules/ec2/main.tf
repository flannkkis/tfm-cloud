# Subir la clave pública a AWS
resource "aws_key_pair" "main" {
  key_name   = "${var.project}-key"
  public_key = file(var.public_key_path)

  tags = {
    Project = var.project
  }
}

# AMI más reciente de Amazon Linux 2023 (gratuita)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Bastión Host
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"  # Free tier
  subnet_id                   = var.public_subnet_id
  vpc_security_group_ids      = [var.sg_bastion_id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true

  # Deshabilitar acceso por contraseña, solo clave SSH
  user_data = <<-EOF
    #!/bin/bash
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd

    # Instalar herramientas de auditoría
    dnf install -y audit fail2ban-all
    systemctl enable auditd fail2ban
    systemctl start auditd fail2ban

    # Log de accesos al bastión
    echo "session required pam_tty_audit.so enable=*" >> /etc/pam.d/sshd
  EOF

  metadata_options {
    http_tokens = "required"  # IMDSv2 obligatorio — evita SSRF contra metadata
  }

  root_block_device {
    encrypted = true  # Disco cifrado
  }

  tags = {
    Name        = "${var.project}-bastion"
    Environment = var.environment
    Role        = "bastion"
    Project     = var.project
  }
}

# Servidor de aplicación (en subred privada)
resource "aws_instance" "app" {
  count                       = var.app_instance_count
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.private_app_subnet_ids[count.index % length(var.private_app_subnet_ids)]
  vpc_security_group_ids      = [var.sg_app_id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = false  # Sin IP pública: solo accesible desde bastión

  iam_instance_profile = var.app_instance_profile

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y nginx amazon-cloudwatch-agent

    # Configurar CloudWatch Agent para enviar logs
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 -s \
      -c ssm:/cloudwatch-agent-config

    systemctl enable nginx
    systemctl start nginx
  EOF

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name        = "${var.project}-app-${count.index + 1}"
    Environment = var.environment
    Role        = "app"
    Project     = var.project
  }
}
