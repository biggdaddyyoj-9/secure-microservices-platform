output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "API server endpoint for the EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Base64 encoded certificate data required for cluster authentication"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_group_name" {
  description = "Name of the default EKS node group"
  value       = aws_eks_node_group.default.node_group_name
}

output "node_group_arn" {
  description = "ARN of the default EKS node group"
  value       = aws_eks_node_group.default.arn
}

output "node_instance_role_arn" {
  description = "IAM role ARN attached to the node group instances"
  value       = var.node_role_arn
}
