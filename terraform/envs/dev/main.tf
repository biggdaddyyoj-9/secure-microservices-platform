provider "aws" {                         # Declares AWS as the cloud provider for this Terraform configuration
  region = var.region                    # Sets the AWS region dynamically using a variable (e.g., us-east-1)
}

# VPC Module

data "aws_availability_zones" "available" {}  # Fetches a list of available AZs in the selected region for high availability

module "vpc" {                              # Instantiates the VPC module to provision networking resources
  source                  = "../../modules/vpc"              # Points to the reusable VPC module source code
  vpc_cidr                = "10.0.0.0/16"                    # Defines the CIDR block for the entire VPC
  public_subnet_cidrs     = var.public_subnet_cidrs         # Specifies CIDRs for public subnets (used for NAT, IGW)
  private_subnet_cidrs    = var.private_subnet_cidrs        # Specifies CIDRs for private subnets (used for EKS nodes)
  availability_zones      = var.availability_zones          # Distributes subnets across multiple AZs for fault tolerance
  region                  = var.region                      # Passes the region to the module for resource alignment
  enable_flow_logs        = true                            # Enables VPC flow logs for traffic monitoring and auditing
  log_group_name          = "/vpc-flow-logs"                # Defines the CloudWatch log group name for flow logs
  tags = {                                                  # Applies consistent tagging for resource tracking and cost allocation
    Project     = "secure-microservices-platform"           # Identifies the project name
    Environment = "dev"                                     # Marks the environment (dev, staging, prod)
    Owner       = "John"                                    # Indicates resource ownership for accountability
  }
}

# IAM Module
module "iam" {                          # Instantiates the IAM module to provision roles and policies for EKS
  source = "../../modules/iam"         # Points to the reusable IAM module source code
}

# EKS Module
module "eks" {                          # Instantiates the EKS module to deploy the Kubernetes control plane and node group
  source              = "../../modules/eks"                 # Points to the reusable EKS module source code
  cluster_name        = "secure-platform-dev"               # Sets the name of the EKS cluster
  region              = var.region                          # Ensures all EKS resources are created in the correct region
  vpc_id              = module.vpc.vpc_id                   # Connects the EKS cluster to the VPC created earlier
  subnet_ids          = module.vpc.private_subnet_ids       # Assigns private subnets for node group placement
  node_group_config   = var.node_group_config               # Passes scaling parameters (desired, min, max) for the node group
  cluster_role_arn    = module.iam.eks_cluster_role_arn     # IAM role for the EKS control plane to manage AWS resources
  node_role_arn       = module.iam.eks_node_role_arn        # IAM role for EC2 nodes to interact with EKS and pull container images
  environment         = "dev"                               # Tags the cluster environment for context and cost tracking
  tags = {                                                  # Applies consistent tagging to all EKS resources
    Environment = "dev"                                     # Marks the environment (dev, staging, prod)
    Owner       = "John"                                    # Indicates resource ownership for accountability
  }
}

