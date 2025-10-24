# VPC Outputs

output "vpc_id" {                                         # Exposes the VPC ID for use in other modules or external tooling
  description = "The ID of the VPC"                       # Human-readable description for clarity
  value       = module.vpc.vpc_id                         # Retrieves the VPC ID from the VPC module
}

output "public_subnet_ids" {                              # Outputs the list of public subnet IDs
  description = "List of public subnet IDs"               # Useful for routing, NAT, or public-facing resources
  value       = module.vpc.public_subnet_ids              # Retrieves public subnet IDs from the VPC module
}

output "private_subnet_ids" {                             # Outputs the list of private subnet IDs
  description = "List of private subnet IDs"              # Used for internal workloads like EKS nodes
  value       = module.vpc.private_subnet_ids             # Retrieves private subnet IDs from the VPC module
}

output "nat_gateway_id" {                                 # Outputs the NAT Gateway ID
  description = "The ID of the NAT Gateway"               # Useful for debugging or routing verification
  value       = module.vpc.nat_gateway_id                 # Retrieves NAT Gateway ID from the VPC module
}

output "flow_log_id" {                                    # Outputs the ID of the VPC Flow Log
  description = "The ID of the VPC Flow Log"              # Enables tracking and auditing of network traffic
  value       = module.vpc.flow_log_id                    # Retrieves Flow Log ID from the VPC module
}

# IAM Outputs

output "eks_cluster_role_arn" {                           # Outputs the IAM role ARN for the EKS control plane
  description = "IAM role ARN for the EKS control plane"  # Required for cluster creation and management
  value       = module.iam.eks_cluster_role_arn           # Retrieves the role ARN from the IAM module
}

output "eks_node_role_arn" {                              # Outputs the IAM role ARN for the EKS node group
  description = "IAM role ARN for the EKS node group"     # Required for EC2 nodes to interact with EKS and AWS services
  value       = module.iam.eks_node_role_arn              # Retrieves the role ARN from the IAM module
}

# EKS Outputs

output "eks_cluster_name" {                               # Outputs the name of the EKS cluster
  description = "Name of the EKS cluster"                 # Useful for CLI access, kubeconfig, and monitoring
  value       = module.eks.cluster_name                   # Retrieves the cluster name from the EKS module
}

output "eks_cluster_endpoint" {                           # Outputs the API server endpoint for the EKS cluster
  description = "API server endpoint for the EKS cluster" # Used by kubectl and CI/CD tools to interact with the cluster
  value       = module.eks.cluster_endpoint               # Retrieves the endpoint from the EKS module
}

output "eks_cluster_ca_certificate" {                     # Outputs the cluster's CA certificate in base64 format
  description = "Base64 encoded certificate data for cluster authentication"  # Required for secure kubeconfig setup
  value       = module.eks.cluster_ca_certificate         # Retrieves the certificate from the EKS module
}

output "eks_node_group_name" {                            # Outputs the name of the default EKS node group
  description = "Name of the default EKS node group"      # Useful for scaling, monitoring, and debugging
  value       = module.eks.node_group_name                # Retrieves the node group name from the EKS module
}

output "eks_node_group_arn" {                             # Outputs the ARN of the default EKS node group
  description = "ARN of the default EKS node group"       # Used for IAM policy attachment and resource tracking
  value       = module.eks.node_group_arn                 # Retrieves the node group ARN from the EKS module
}
