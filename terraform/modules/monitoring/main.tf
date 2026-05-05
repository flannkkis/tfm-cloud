# S3 bucket para almacenar los logs de CloudTrail
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "${var.project}-cloudtrail-logs-${var.account_id}"
  force_destroy = false

  tags = {
    Name        = "${var.project}-cloudtrail-logs"
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Política del bucket — solo CloudTrail puede escribir en él
resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${var.account_id}/*"
        Condition = {
          StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      }
    ]
  })
}

# CloudTrail — auditoría de todas las llamadas a la API de AWS
resource "aws_cloudtrail" "main" {
  name                          = "${var.project}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true  # Detecta si los logs han sido manipulados

  tags = {
    Name        = "${var.project}-trail"
    Environment = var.environment
    Project     = var.project
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]
}

# Grupo de logs en CloudWatch
resource "aws_cloudwatch_log_group" "app" {
  name              = "/tfm/${var.environment}/app"
  retention_in_days = 90

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

resource "aws_cloudwatch_log_group" "bastion" {
  name              = "/tfm/${var.environment}/bastion"
  retention_in_days = 90

  tags = {
    Environment = var.environment
    Project     = var.project
  }
}

# Alarma: CPU alta en cualquier instancia (posible ataque DoS o malware)
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.project}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU superior al 80% durante 10 minutos"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  tags = {
    Project = var.project
  }
}

# SNS Topic para recibir alertas por email
resource "aws_sns_topic" "alerts" {
  name = "${var.project}-alerts"

  tags = {
    Project = var.project
  }
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# Alarma: intentos de login fallidos en el bastión (detección de fuerza bruta)
resource "aws_cloudwatch_log_metric_filter" "ssh_failures" {
  name           = "${var.project}-ssh-failures"
  pattern        = "Failed password"
  log_group_name = aws_cloudwatch_log_group.bastion.name

  metric_transformation {
    name      = "SSHFailedLogins"
    namespace = "${var.project}/Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "ssh_brute_force" {
  alarm_name          = "${var.project}-ssh-brute-force"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "SSHFailedLogins"
  namespace           = "${var.project}/Security"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "Mas de 10 fallos SSH en 5 minutos — posible fuerza bruta"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
