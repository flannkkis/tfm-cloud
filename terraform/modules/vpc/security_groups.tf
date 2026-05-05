# SG del Bastión Host — solo SSH desde tu IP
resource "aws_security_group" "bastion" {
  name        = "${var.project}-sg-bastion"
  description = "Acceso SSH al bastion host solo desde IP autorizada"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH desde IP de administrador"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    description = "Salida libre"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-sg-bastion"
    Environment = var.environment
  }
}

# SG servidores de aplicación — SSH solo desde el bastión
resource "aws_security_group" "app" {
  name        = "${var.project}-sg-app"
  description = "Acceso SSH al servidor app solo desde el bastion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH desde bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description = "HTTP interno"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "HTTPS interno"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-sg-app"
    Environment = var.environment
  }
}

# SG base de datos — solo desde servidores de aplicación
resource "aws_security_group" "db" {
  name        = "${var.project}-sg-db"
  description = "Acceso a base de datos solo desde capa de aplicacion"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL/Aurora desde app"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-sg-db"
    Environment = var.environment
  }
}
