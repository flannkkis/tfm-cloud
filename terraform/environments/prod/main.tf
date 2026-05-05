data "aws_caller_identity" "current" {}

module "vpc" {
  source = "../../modules/vpc"

  project                  = var.project
  environment              = var.environment
  vpc_cidr                 = var.vpc_cidr
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  availability_zones       = var.availability_zones
  admin_ip                 = var.admin_ip
}

module "iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = var.environment
}

module "ec2" {
  source = "../../modules/ec2"

  project                = var.project
  environment            = var.environment
  public_key_path        = var.public_key_path
  public_subnet_id       = module.vpc.public_subnet_ids[0]
  private_app_subnet_ids = module.vpc.private_app_subnet_ids
  sg_bastion_id          = module.vpc.sg_bastion_id
  sg_app_id              = module.vpc.sg_app_id
  app_instance_count     = var.app_instance_count
  app_instance_profile   = module.iam.app_instance_profile_name
}

module "rds" {
  source = "../../modules/rds"

  project               = var.project
  environment           = var.environment
  private_db_subnet_ids = module.vpc.private_db_subnet_ids
  sg_db_id              = module.vpc.sg_db_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
}

module "monitoring" {
  source = "../../modules/monitoring"

  project     = var.project
  environment = var.environment
  account_id  = data.aws_caller_identity.current.account_id
  alert_email = var.alert_email
}
