output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = try(aws_nat_gateway.nat[0].id, null)
}

output "flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = try(aws_flow_log.vpc[0].id, null)
}
output "vpc_endpoint_s3_id" {
  description = "ID of the VPC Gateway Endpoint for S3"
  value       = aws_vpc_endpoint.s3.id
}

output "vpc_endpoint_dynamodb_id" {
  description = "ID of the VPC Gateway Endpoint for DynamoDB"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "vpc_endpoint_cloudwatch_logs_id" {
  description = "ID of the VPC Interface Endpoint for CloudWatch Logs"
  value       = aws_vpc_endpoint.cloudwatch_logs.id
}
