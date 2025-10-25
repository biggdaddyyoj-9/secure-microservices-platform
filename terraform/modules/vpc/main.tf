provider "aws" {                                                       # Declares AWS as the cloud provider
  region = "us-east-1"                                                 # Sets the region for all resources
}

data "aws_region" "current" {}                                         # Retrieves the current AWS region (used for dynamic references)

resource "aws_vpc" "main" {                                            # Creates the main VPC for your infrastructure
  cidr_block           = var.vpc_cidr                                  # Defines the IP range for the VPC
  enable_dns_support   = true                                          # Enables DNS resolution within the VPC
  enable_dns_hostnames = true                                          # Enables DNS hostnames for EC2 instances
  tags                 = var.tags                                      # Applies custom tags for tracking and organization
}

resource "aws_internet_gateway" "igw" {                                # Provisions an Internet Gateway for public subnet access
  vpc_id = aws_vpc.main.id                                             # Associates the IGW with the main VPC
  tags   = var.tags                                                    # Applies custom tags for tracking and organization
}

resource "aws_subnet" "public" {                                       # Creates public subnets for NAT Gateway and internet-facing resources
  count                   = length(var.public_subnet_cidrs)            # Iterates over the list of public subnet CIDRs
  vpc_id                  = aws_vpc.main.id                            # Associates each subnet with the main VPC
  cidr_block              = var.public_subnet_cidrs[count.index]       # Assigns a unique CIDR block to each public subnet
  map_public_ip_on_launch = true                                       # Automatically assigns public IPs to instances in this subnet
  availability_zone       = var.availability_zones[count.index]        # Distributes subnets across availability zones
  tags                    = merge(var.tags, { "Tier" = "Public" })     # Adds a "Tier" tag to distinguish public subnets
}

resource "aws_subnet" "private" {                                      # Creates private subnets for internal workloads like EKS nodes
  count             = length(var.private_subnet_cidrs)                 # Iterates over the list of private subnet CIDRs
  vpc_id            = aws_vpc.main.id                                  # Associates each subnet with the main VPC
  cidr_block        = var.private_subnet_cidrs[count.index]            # Assigns a unique CIDR block to each private subnet
  availability_zone = var.availability_zones[count.index]             # Distributes subnets across availability zones
  tags              = merge(var.tags, { "Tier" = "Private" })          # Adds a "Tier" tag to distinguish private subnets
}

resource "aws_eip" "nat" {                                             # Allocates an Elastic IP for the NAT Gateway
  count = var.enable_nat_gateway ? 1 : 0                               # Creates the EIP only if NAT Gateway is enabled
  tags  = { Name = "nat-eip" }                                         # Tags the EIP for identification
}

resource "aws_nat_gateway" "nat" {                                     # Provisions a NAT Gateway for outbound internet access from private subnets
  count         = var.enable_nat_gateway ? 1 : 0                       # Creates the NAT Gateway only if enabled
  allocation_id = aws_eip.nat[0].id                                    # Associates the NAT Gateway with the allocated EIP
  subnet_id     = aws_subnet.public[0].id                              # Places the NAT Gateway in the first public subnet
  tags          = var.tags                                            # Applies custom tags for tracking and organization
}

resource "aws_route_table" "public" {                                  # Creates a route table for public subnets
  vpc_id = aws_vpc.main.id                                             # Associates the route table with the main VPC
  tags   = var.tags                                                    # Applies custom tags for tracking and organization
}


resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = var.tags
}

resource "aws_route" "private_nat" {
  count                  = var.enable_nat_gateway ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_flow_logs ? 1 : 0
name_prefix         = "${var.log_group_name}-"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_iam_role" "flow_logs_role" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "vpc-flow-logs-policy"
  role  = aws_iam_role.flow_logs_role[0].id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
    }]
  })
}

resource "aws_flow_log" "vpc" {
  count                 = var.enable_flow_logs ? 1 : 0
  log_destination       = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  log_destination_type  = "cloud-watch-logs"
  traffic_type          = "ALL"
  iam_role_arn          = aws_iam_role.flow_logs_role[0].arn
  vpc_id                = aws_vpc.main.id

  depends_on = [
    aws_vpc.main,
    aws_iam_role.flow_logs_role,
    aws_cloudwatch_log_group.vpc_flow_logs
  ]
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-cloudwatch-logs-sg"
  description = "Security group for CloudWatch Logs VPC endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type  = "Interface"
  subnet_ids = [for s in aws_subnet.private : s.id]
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    Name        = "vpc-endpoint-cloudwatch-logs"
    Environment = "dev"
    Owner       = "john"
    Project     = "secure-microservices-platform"
    Purpose     = "private-access-to-cloudwatch-logs"
  }
}
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
}
