variable "vpc_cidr" {                                                  # Defines the CIDR block for the entire VPC
  description = "CIDR block for the VPC"                               # Explains the purpose of the VPC IP range
  type        = string                                                 # Expects a single string value
  default     = "10.0.0.0/16"                                          # Default CIDR block for a large private network
}

variable "public_subnet_cidrs" {                                       # CIDRs for public-facing subnets
  description = "List of CIDRs for public subnets"                     # Used for NAT Gateway, IGW, and public resources
  type        = list(string)                                           # Expects a list of CIDR strings
  default     = ["10.0.1.0/24", "10.0.2.0/24"]                          # Default public subnet ranges
}

variable "private_subnet_cidrs" {                                      # CIDRs for internal/private subnets
  description = "List of CIDRs for private subnets"                    # Used for EKS nodes and internal services
  type        = list(string)                                           # Expects a list of CIDR strings
  default     = ["10.0.3.0/24", "10.0.4.0/24"]                          # Default private subnet ranges
}

variable "region" {                                                    # AWS region for resource deployment
  description = "AWS region to deploy resources"                       # Ensures all resources are created in the same region
  type        = string                                                 # Expects a string (e.g., "us-east-1")
  default     = "us-east-1"                                            # Default region for deployment
}

variable "enable_flow_logs" {                                          # Flag to enable or disable VPC flow logs
  description = "Enable VPC flow logs"                                 # Controls whether traffic logging is enabled
  type        = bool                                                   # Expects a boolean value
  default     = true                                                   # Enables flow logs by default
}

variable "log_group_name" {                                            # Name of the CloudWatch log group for flow logs
  description = "CloudWatch log group name for flow logs"              # Used to organize and store VPC traffic logs
  type        = string                                                 # Expects a string value
  default     = "/vpc-flow-logs"                                       # Default log group name
}

variable "tags" {                                                      # Common tags applied to all resources
  description = "Common tags to apply to all resources"                # Helps with cost allocation and resource tracking
  type        = map(string)                                            # Expects a map of key-value string pairs
  default     = {                                                      # Default tags for project identification
    Project     = "secure-microservices-platform"                      # Project name tag
    Environment = "dev"                                                # Environment tag (e.g., dev, staging, prod)
  }
}

variable "availability_zones" {                                        # List of AZs for subnet distribution
  description = "List of availability zones for subnets"               # Ensures high availability across multiple zones
  type        = list(string)                                           # Expects a list of AZ names (e.g., ["us-east-1a", "us-east-1b"])
}

variable "enable_nat_gateway" {                                        # Flag to enable or disable NAT Gateway
  description = "Enable NAT Gateway for private subnet internet access" # Controls outbound internet access for private subnets
  type        = bool                                                   # Expects a boolean value
  default     = true                                                   # Enables NAT Gateway by default
}
