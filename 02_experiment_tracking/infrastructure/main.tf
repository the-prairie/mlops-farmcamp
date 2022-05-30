terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {}



module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14.0"

  name = var.vpc_name
  cidr = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  azs              = var.vpc_azs
  private_subnets  = var.vpc_private_subnets
  public_subnets   = var.vpc_public_subnets
  database_subnets = var.vpc_database_subnets

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  manage_default_route_table = true
  default_route_table_tags   = { Name = "mlops-terraform" }

  enable_nat_gateway = var.vpc_enable_nat_gateway

  tags = var.vpc_tags
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"

  name = "mlops-ec2"

  ami                    = "ami-0843f7c45354d48b5"
  instance_type          = "t2.micro"
  key_name               = module.key_pair.key_pair_key_name
  vpc_security_group_ids = [module.security_group_ec2.security_group_id]
  subnet_id              = element(module.vpc.private_subnets, 0)
  associate_public_ip_address = true


  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "mlops_aws"
  public_key = tls_private_key.this.public_key_openssh
}

module "security_group_ec2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "mlops-ec2-sg"
  description = "Security group for usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0", module.vpc.vpc_cidr_block]
  ingress_rules       = ["https-443-tcp", "http-80-tcp", "ssh-tcp","postgresql-tcp"]
  egress_rules        = ["all-all"]

  tags = var.sg_tags
}

module "security_group_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "mlops-rds-sg"
  description = "Security group for usage with RDS instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0", module.vpc.vpc_cidr_block]
  ingress_rules       = ["postgresql-tcp"]
  egress_rules        = ["all-all"]

  tags = var.sg_tags
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "mlflow-rds"

  engine               = "postgres"
  engine_version       = "14.1"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = "mlflow_db"
  username = "db_admin"
  password = random_string.db-password.result
  port     = 5432

  multi_az               = false
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group_rds.security_group_id]

  tags = var.rds_tags

}

resource "random_string" "db-password" {
  length  = 32
  upper   = true
  number  = true
  special = false
}


module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "mlflow-artifacts-remore"
  acl    = "private"

  versioning = {
    enabled = false
  }

  tags = var.s3_tags

}