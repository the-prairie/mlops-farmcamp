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

locals {

  user_data = <<EOT
  #!/bin/bash
  sudo yum update
  pip3 install mlflow boto3 psycopg2-binary

  EOT

  user_data_prefect = <<EOT
  #!/bin/bash
  sudo apt-get update
  sudo apt update 
  sudo apt install python3-pip
  pip3 install virtualenv

  EOT

  tags = {
    Owner       = "mlops"
    Environment = "dev"
  }
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14.0"

  name                 = var.vpc_name
  cidr                 = var.vpc_cidr
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

  ami                         = "ami-0843f7c45354d48b5"
  instance_type               = "t2.micro"
  key_name                    = "mlops"
  vpc_security_group_ids      = [module.security_group_ec2.security_group_id]
  subnet_id                   = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = true

  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = true


  tags = {
    Terraform   = "true"
    Environment = "prod"
    Name        = "ec2-main-public"
  }
}

module "ec2_prefect" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 4.0"

  name = "mlops-ec2-prefect"

  ami                         = "ami-0fb99f22ad0184043"
  instance_type               = "t2.micro"
  key_name                    = "mlops"
  vpc_security_group_ids      = [module.security_group_ec2_prefect.security_group_id]
  subnet_id                   = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = true

  user_data_base64            = base64encode(local.user_data_prefect)
  user_data_replace_on_change = true


  tags = {
    Terraform   = "true"
    Environment = "prod"
    Name        = "ec2-prefect-public"
  }
}

module "security_group_ec2" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "mlops-ec2-sg"
  description = "Security group for usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0", module.vpc.vpc_cidr_block]
  ingress_rules       = ["https-443-tcp", "http-80-tcp", "ssh-tcp", "postgresql-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 5000
      to_port     = 5000
      protocol    = "tcp"
      description = "Accept inbound from mlflow server."
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  
  # computed_ingress_with_cidr_blocks = [
  #   {
  #     rule        = "https-443-tcp"
  #     cidr_blocks = "0.0.0.0/0, ${module.vpc.vpc_cidr_block}"
  #   },
  #   {
  #     from_port   = 5000
  #     to_port     = 5000
  #     protocol    = 6
  #     description = "Service name with vpc cidr"
  #     cidr_blocks = module.vpc.vpc_cidr_block
  #   }
  # ]
  # number_of_computed_ingress_with_cidr_blocks = 2

  egress_rules        = ["all-all"]

  tags = var.sg_tags
}

module "security_group_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "mlops-rds-sg"
  description = "Security group for usage with RDS instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = [module.vpc.vpc_cidr_block]
  ingress_rules       = ["postgresql-tcp"]

  ingress_with_source_security_group_id = [
    {
      description              = "Allow access from ec2 security group."
      rule                     = "postgresql-tcp"
      source_security_group_id =  module.security_group_ec2.security_group_id
    },
    {
      description              = "Allow ssh access from ec2 security group."
      rule                     = "ssh-tcp"
      source_security_group_id =  module.security_group_ec2.security_group_id
    },
  ]

  egress_rules        = ["all-all"]

  tags = var.sg_tags
}

module "security_group_ec2_prefect" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "mlops-ec2-sg-prefect"
  description = "Security group for usage with EC2 instance for hosting Prefect"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0", module.vpc.vpc_cidr_block]
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 4200
      to_port     = 4200
      protocol    = "tcp"
      description = "Accept inbound from Prefect."
      cidr_blocks = "0.0.0.0/0"
    }
  ]

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
  publicly_accessible = false

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