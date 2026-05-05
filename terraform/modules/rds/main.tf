# Subnet group — le dice a RDS en qué subredes puede crear instancias
resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.private_db_subnet_ids

  tags = {
    Name        = "${var.project}-db-subnet-group"
    Environment = var.environment
  }
}

# Parámetros de seguridad de MySQL
resource "aws_db_parameter_group" "main" {
  family = "mysql8.0"
  name   = "${var.project}-db-params"

  parameter {
    name  = "general_log"
    value = "1"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  tags = {
    Name    = "${var.project}-db-params"
    Project = var.project
  }
}

resource "aws_db_instance" "main" {
  identifier        = "${var.project}-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"  # Free tier
  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true  # Cifrado en reposo

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.sg_db_id]
  parameter_group_name   = aws_db_parameter_group.main.name

  publicly_accessible     = false  # Solo accesible desde dentro de la VPC
  multi_az                = false  # Free tier: una sola AZ
  backup_retention_period = 0      # 0 días de backups automáticos
  deletion_protection     = true   # Evita borrado accidental

  skip_final_snapshot = true
}
