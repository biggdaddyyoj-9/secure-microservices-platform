variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDRs for private subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones for subnets"
}

variable "region" {
  type        = string
  description = "AWS region to deploy resources"
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
