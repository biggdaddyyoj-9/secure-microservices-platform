output "vpc_id" {                                                      # Outputs the ID of the main VPC
  description = "The ID of the VPC"                                    # Describes the purpose of this output
  value       = aws_vpc.main.id                                        # Retrieves the VPC ID from the aws_vpc resource
}

output "public_subnet_ids" {                                           # Outputs a list of public subnet IDs
  description = "List of public subnet IDs"                            # Useful for routing, NAT, and public-facing resources
  value       = aws_subnet.public[*].id                                # Collects all public subnet IDs using splat syntax
}

output "private_subnet_ids" {                                          # Outputs a list of private subnet IDs
  description = "List of private subnet IDs"                           # Used for internal workloads like EKS nodes
  value       = aws_subnet.private[*].id                               # Collects all private subnet IDs using splat syntax
}

output "nat_gateway_id" {                                              # Outputs the ID of the NAT Gateway
  description = "The ID of the NAT Gateway"                            # Useful for debugging and routing verification
  value       = try(aws_nat_gateway.nat[0].id, null)                   # Safely retrieves the NAT Gateway ID if it exists
}

output "flow_log_id" {                                                 # Outputs the ID of the VPC Flow Log
  description = "The ID of the VPC Flow Log"                           # Enables tracking and auditing of network traffic
  value       = try(aws_flow_log.vpc[0].id, null)                      # Safely retrieves the Flow Log ID if it exists
}

output "vpc_endpoint_s3_id" {                                          # Outputs the ID of the VPC Gateway Endpoint for S3
  description = "ID of the VPC Gateway Endpoint for S3"                # Useful for verifying private access to S3
  value       = aws_vpc_endpoint.s3.id                                 # Retrieves the endpoint ID from the s3 VPC endpoint resource
}

output "vpc_endpoint_cloudwatch_logs_id" {                             # Outputs the ID of the VPC Interface Endpoint for CloudWatch Logs
  description = "ID of the VPC Interface Endpoint for CloudWatch Logs" # Useful for verifying private access to CloudWatch Logs
  value       = aws_vpc_endpoint.cloudwatch_logs.id                    # Retrieves the endpoint ID from the CloudWatch Logs VPC endpoint resource
}
