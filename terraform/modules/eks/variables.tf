variable "cluster_name" {                                              # Defines the name of the EKS cluster
  type        = string                                                 # Expects a string input
  description = "Name of the EKS cluster"                              # Describes the purpose of this variable
}

variable "region" {                                                    # Specifies the AWS region for resource deployment
  type        = string                                                 # Expects a string input (e.g., "us-east-1")
  description = "AWS region to deploy the cluster"                     # Describes the purpose of this variable
}

variable "vpc_id" {                                                    # ID of the VPC where the EKS cluster will be deployed
  type        = string                                                 # Expects a string input (e.g., "vpc-abc123")
  description = "VPC ID where the EKS cluster will be deployed"        # Describes the purpose of this variable
}

variable "subnet_ids" {                                                # List of subnet IDs for EKS control plane and node groups
  type        = list(string)                                           # Expects a list of strings
  description = "List of subnet IDs for EKS control plane and node groups"  # Describes the purpose of this variable
}

variable "node_group_config" {                                         # Configuration block for the default EKS node group
  type = object({                                                      # Defines a structured object with scaling and instance type settings
    instance_types = list(string)                                      # List of EC2 instance types (e.g., ["t3.micro"])
    desired_size   = number                                            # Desired number of nodes to launch
    max_size       = number                                            # Maximum number of nodes allowed
    min_size       = number                                            # Minimum number of nodes to maintain availability
  })
  description = "Configuration for the default node group"             # Describes the purpose of this variable
}

variable "kubernetes_version" {                                        # Specifies the Kubernetes version for the EKS cluster
  type        = string                                                 # Expects a string input (e.g., "1.28")
  default     = "1.28"                                                 # Sets a default version to simplify usage
  description = "Kubernetes version for the EKS cluster"               # Describes the purpose of this variable
}

variable "cluster_role_arn" {                                          # IAM role ARN for the EKS control plane
  type        = string                                                 # Expects a string input (e.g., "arn:aws:iam::123456789012:role/eks-cluster-role")
  description = "IAM role ARN for the EKS control plane"               # Describes the purpose of this variable
}

variable "node_role_arn" {                                             # IAM role ARN for the EKS node group
  type        = string                                                 # Expects a string input (e.g., "arn:aws:iam::123456789012:role/eks-node-role")
  description = "IAM role ARN for the EKS node group"                  # Describes the purpose of this variable
}

variable "tags" {                                                      # Key-value tags to apply to all EKS resources
  type        = map(string)                                            # Expects a map of strings
  default     = {}                                                     # Defaults to an empty map if no tags are provided
  description = "Tags to apply to all EKS resources"                   # Describes the purpose of this variable
}

variable "environment" {                                               # Specifies the deployment environment (e.g., dev, staging, prod)
  description = "Deployment environment (e.g., dev, staging, prod)"    # Describes the purpose of this variable
  type        = string                                                 # Expects a string input
}
