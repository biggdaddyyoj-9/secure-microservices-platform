module "vpc" {
  source               = "../../modules/vpc"
  region               = var.region
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones = var.availability_zones
  enable_flow_logs     = true
  log_group_name       = "/vpc-flow-logs"
  tags = {
    Project     = "secure-microservices-platform"
    Environment = "dev"
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
  
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = module.vpc.nat_gateway_id
}

output "flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = module.vpc.flow_log_id
}
