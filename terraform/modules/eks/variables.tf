variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the cluster"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the EKS cluster will be deployed"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for EKS control plane and node groups"
}

variable "node_group_config" {
  type = object({
    instance_types = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
  })
  description = "Configuration for the default node group"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.28"
  description = "Kubernetes version for the EKS cluster"
}

variable "cluster_role_arn" {
  type        = string
  description = "IAM role ARN for the EKS control plane"
}

variable "node_role_arn" {
  type        = string
  description = "IAM role ARN for the EKS node group"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all EKS resources"
}
