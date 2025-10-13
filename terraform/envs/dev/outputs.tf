# VPC Outputs
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

# IAM Outputs
output "eks_cluster_role_arn" {
  description = "IAM role ARN for the EKS control plane"
  value       = module.iam.eks_cluster_role_arn
}

output "eks_node_role_arn" {
  description = "IAM role ARN for the EKS node group"
  value       = module.iam.eks_node_role_arn
}

# EKS Outputs
output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "API server endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_ca_certificate" {
  description = "Base64 encoded certificate data for cluster authentication"
  value       = module.eks.cluster_ca_certificate
}

output "eks_node_group_name" {
  description = "Name of the default EKS node group"
  value       = module.eks.node_group_name
}

output "eks_node_group_arn" {
  description = "ARN of the default EKS node group"
  value       = module.eks.node_group_arn
}
