output "eks_cluster_role_arn" {                                        # Outputs the IAM role ARN for the EKS control plane
  value = aws_iam_role.eks_cluster.arn                                # Retrieves the ARN from the eks_cluster IAM role resource
}

output "eks_node_role_arn" {                                          # Outputs the IAM role ARN for the EKS node group
  value = aws_iam_role.eks_node.arn                                   # Retrieves the ARN from the eks_node IAM role resource
}
