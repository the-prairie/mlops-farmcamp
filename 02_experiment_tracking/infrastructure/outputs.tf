output "vpc_public_subnets" {
  description = "IDs of the VPC's public subnets"
  value       = module.vpc.public_subnets
}

output "ec2_instance_public_ips" {
  description = "Public IP addresses of EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "ec2_instance_public_dns" {
  value = module.ec2_instance.public_dns
}


output "db_username" {
  description = "Username for db"
  value       = module.db.db_instance_username
  sensitive = true
}

output "db_host_address" {
  description = "Host address for PostgreSQL database"
  value = module.db.db_instance_address 
}


# output "tls_private_key" {
#   description = "Private key for EC2 instance"
#   value       = tls_private_key.this.private_key_pem
#   sensitive   = true
# }