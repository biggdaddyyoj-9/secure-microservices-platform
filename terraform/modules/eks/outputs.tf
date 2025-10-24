output "cluster_name" {                                                # Outputs the name of the EKS cluster
  description = "Name of the EKS cluster"                              # Describes the purpose of this output
  value       = aws_eks_cluster.this.name                              # Retrieves the cluster name from the EKS cluster resource
}

output "cluster_endpoint" {                                            # Outputs the API server endpoint for the EKS cluster
  description = "API server endpoint for the EKS cluster"              # Used by kubectl and CI/CD tools to interact with the cluster
  value       = aws_eks_cluster.this.endpoint                          # Retrieves the endpoint from the EKS cluster resource
}

output "cluster_ca_certificate" {                                      # Outputs the base64-encoded CA certificate for authentication
  description = "Base64 encoded certificate data required for cluster authentication"  # Required for secure kubeconfig setup
  value       = aws_eks_cluster.this.certificate_authority[0].data     # Retrieves the certificate data from the EKS cluster resource
}

output "node_group_name" {                                             # Outputs the name of the default EKS node group
  description = "Name of the default EKS node group"                   # Useful for scaling, monitoring, and debugging
  value       = aws_eks_node_group.default.node_group_name             # Retrieves the node group name from the node group resource
}

output "node_group_arn" {                                              # Outputs the ARN of the default EKS node group
  description = "ARN of the default EKS node group"                    # Used for IAM policy attachment and resource tracking
  value       = aws_eks_node_group.default.arn                         # Retrieves the node group ARN from the node group resource
}

output "node_instance_role_arn" {                                      # Outputs the IAM role ARN attached to the node group EC2 instances
  description = "IAM role ARN attached to the node group instances"    # Required for nodes to interact with EKS and AWS services
  value       = var.node_role_arn                                      # Retrieves the role ARN from the input variable
}
