provider "aws" {
  region = var.region
}

# VPC Module

data "aws_availability_zones" "available" {}

module "vpc" {
  source                  = "../../modules/vpc"
  vpc_cidr                = "10.0.0.0/16"
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  availability_zones      = var.availability_zones
  region                  = var.region
  enable_flow_logs        = true
  log_group_name          = "/vpc-flow-logs"
  tags = {
    Project     = "secure-microservices-platform"
    Environment = "dev"
    Owner       = "John"
  }
}

# IAM Module
module "iam" {
  source = "../../modules/iam"
}
# EKS Module
module "eks" {
  source              = "../../modules/eks"
  cluster_name        = "secure-platform-dev"
  region              = var.region
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  node_group_config   = var.node_group_config
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_role_arn       = module.iam.eks_node_role_arn
  environment         = "dev"  
  tags = {
    Environment = "dev"
    Owner       = "John"
  }
}
