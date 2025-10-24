variable "public_subnet_cidrs" {                      # Defines the CIDR blocks for public subnets (used for NAT, IGW, and public-facing resources)
  type        = list(string)                          # Expects a list of strings (e.g., ["10.0.1.0/24", "10.0.2.0/24"])
  description = "CIDRs for public subnets"            # Describes the purpose of this variable for documentation and clarity
}

variable "private_subnet_cidrs" {                     # Defines the CIDR blocks for private subnets (used for EKS nodes and internal services)
  type        = list(string)                          # Expects a list of strings (e.g., ["10.0.3.0/24", "10.0.4.0/24"])
  description = "CIDRs for private subnets"           # Describes the purpose of this variable for documentation and clarity
}

variable "availability_zones" {                       # Specifies which AZs to use for subnet distribution and high availability
  type        = list(string)                          # Expects a list of AZ names (e.g., ["us-east-1a", "us-east-1b"])
  description = "Availability zones for subnets"      # Describes the purpose of this variable for documentation and clarity
}

variable "node_group_config" {                        # Defines scaling and instance type configuration for the EKS node group
  type = object({                                     # Uses an object type to group related node group settings
    instance_types = list(string)                     # List of EC2 instance types (e.g., ["t3.micro"])
    desired_size   = number                           # Number of nodes to launch initially
    max_size       = number                           # Maximum number of nodes allowed in the group
    min_size       = number                           # Minimum number of nodes to maintain availability
  })
  description = "Configuration for the default node group"  # Describes the purpose of this variable for documentation and clarity
}

variable "region" {                                   # Specifies the AWS region for all resources
  description = "AWS region for deployment"           # Describes the purpose of this variable for documentation and clarity
  type        = string                                # Expects a single string value (e.g., "us-east-1")
  default     = "us-east-1"                           # Sets a default region to simplify usage and avoid manual input
}
