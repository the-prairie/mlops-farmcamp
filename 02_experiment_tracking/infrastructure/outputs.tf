output "vpc_public_subnets" {
  description = "IDs of the VPC's public subnets"
  value       = module.vpc.public_subnets
}

output "ec2_instance_public_ips" {
  description = "Public IP addresses of EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "tls_private_key" {
    description = "Private key for EC2 instance"
    value     = tls_private_key.this.private_key_pem
    sensitive = true
}