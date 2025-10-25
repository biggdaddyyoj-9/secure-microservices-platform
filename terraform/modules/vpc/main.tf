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

resource "aws_route" "public_internet" {                              # Creates a default route for public subnets to access the internet
  route_table_id         = aws_route_table.public.id                  # Associates the route with the public route table
  destination_cidr_block = "0.0.0.0/0"                                # Matches all outbound traffic
  gateway_id             = aws_internet_gateway.igw.id                # Routes traffic through the Internet Gateway
}

resource "aws_route_table_association" "public" {                     # Associates each public subnet with the public route table
  count          = length(aws_subnet.public)                          # Iterates over all public subnets
  subnet_id      = aws_subnet.public[count.index].id                 # Targets each public subnet by index
  route_table_id = aws_route_table.public.id                         # Associates with the public route table
}

resource "aws_route_table" "private" {                                # Creates a route table for private subnets
  vpc_id = aws_vpc.main.id                                            # Associates the route table with the main VPC
  tags   = var.tags                                                   # Applies custom tags for tracking and organization
}

resource "aws_route" "private_nat" {                                  # Creates a default route for private subnets to access the internet via NAT
  count                  = var.enable_nat_gateway ? 1 : 0             # Only creates the route if NAT Gateway is enabled
  route_table_id         = aws_route_table.private.id                 # Associates the route with the private route table
  destination_cidr_block = "0.0.0.0/0"                                # Matches all outbound traffic
  nat_gateway_id         = aws_nat_gateway.nat[0].id                  # Routes traffic through the NAT Gateway
}

resource "aws_route_table_association" "private" {                    # Associates each private subnet with the private route table
  count          = length(aws_subnet.private)                         # Iterates over all private subnets
  subnet_id      = aws_subnet.private[count.index].id                # Targets each private subnet by index
  route_table_id = aws_route_table.private.id                        # Associates with the private route table
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {                 # Creates a CloudWatch Log Group for VPC flow logs
  count             = var.enable_flow_logs ? 1 : 0                    # Only creates the log group if flow logs are enabled
  name_prefix       = "${var.log_group_name}-"                        # Prefix for the log group name
  retention_in_days = 30                                              # Retains logs for 30 days
  tags              = var.tags                                        # Applies custom tags for tracking and organization
}

resource "aws_iam_role" "flow_logs_role" {                            # IAM role for VPC flow logs to write to CloudWatch
  count = var.enable_flow_logs ? 1 : 0                                # Only creates the role if flow logs are enabled
  name  = "vpc-flow-logs-role"                                        # Sets the name of the IAM role

  assume_role_policy = jsonencode({                                   # Trust policy allowing VPC flow logs service to assume this role
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

resource "aws_iam_role_policy" "flow_logs_policy" {                   # IAM policy granting permissions to write logs to CloudWatch
  count = var.enable_flow_logs ? 1 : 0                                # Only creates the policy if flow logs are enabled
  name  = "vpc-flow-logs-policy"                                      # Sets the name of the policy
  role  = aws_iam_role.flow_logs_role[0].id                           # Attaches the policy to the flow logs role

  policy = jsonencode({                                               # Defines the permissions for log stream creation and event publishing
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*" # Targets all streams under the log group
    }]
  })
}

resource "aws_flow_log" "vpc" {                                       # Enables VPC flow logging to CloudWatch
  count                 = var.enable_flow_logs ? 1 : 0                # Only creates the flow log if enabled
  log_destination       = aws_cloudwatch_log_group.vpc_flow_logs[0].arn # Specifies the CloudWatch log group
  log_destination_type  = "cloud-watch-logs"                          # Sets the destination type
  traffic_type          = "ALL"                                       # Captures all traffic (accepted, rejected, and all)
  iam_role_arn          = aws_iam_role.flow_logs_role[0].arn          # IAM role used to publish logs
  vpc_id                = aws_vpc.main.id                             # VPC to monitor

  depends_on = [                                                     # Ensures dependent resources are created first
    aws_vpc.main,
    aws_iam_role.flow_logs_role,
    aws_cloudwatch_log_group.vpc_flow_logs
  ]
}

resource "aws_security_group" "vpc_endpoint_sg" {                     # Security group for CloudWatch Logs VPC endpoint
  name        = "vpc-endpoint-cloudwatch-logs-sg"                     # Sets the name of the security group
  description = "Security group for CloudWatch Logs VPC endpoint"     # Describes the purpose of the security group
  vpc_id      = aws_vpc.main.id                                       # Associates the SG with the main VPC

  ingress {                                                           # Allows inbound HTTPS traffic from private subnets
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {                                                            # Allows all outbound traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags                                                     # Applies custom tags for tracking and organization
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {                       # Creates an interface VPC endpoint for CloudWatch Logs
  vpc_id             = aws_vpc.main.id                                # Associates the endpoint with the main VPC
  service_name       = "com.amazonaws.${var.region}.logs"             # Specifies the CloudWatch Logs service in the region
  vpc_endpoint_type  = "Interface"                                    # Uses an interface endpoint for private connectivity
  subnet_ids         = [for s in aws_subnet.private : s.id]           # Places the endpoint in private subnets
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]        # Applies the security group to the endpoint
  private_dns_enabled = true                                          # Enables private DNS resolution for the service

  tags = {                                                            # Applies detailed tags for tracking and purpose
    Name        = "vpc-endpoint-cloudwatch-logs"
    Environment = "dev"
    Owner       = "john"
    Project     = "secure-microservices-platform"
    Purpose     = "private-access-to-cloudwatch-logs"
  }
}

resource "aws_vpc_endpoint" "s3" {                                    # Creates a gateway VPC endpoint for S3
  vpc_id            = aws_vpc.main.id                                 # Associates the endpoint with the main VPC
  service_name      = "com.amazonaws.us-east-1.s3"                    # Specifies the S3 service in the region
  vpc_endpoint_type = "Gateway"                                       # Uses a gateway endpoint for routing traffic
  route_table_ids   = [aws_route_table.private.id]                    # Associates the endpoint with the private route table
}

resource "aws_vpc_endpoint" "dynamodb" {                              # Creates a gateway VPC endpoint for DynamoDB
  vpc_id            = aws_vpc.main.id                                 # Associates the endpoint with the main VPC
  service_name      = "com.amazonaws.us-east-1.dynamodb"              # Specifies the DynamoDB service in the region
  vpc_endpoint_type = "Gateway"                                       # Uses a gateway endpoint for routing traffic
  route_table_ids   = [aws_route_table.private.id]                    # Associates the endpoint with the private route table
}
