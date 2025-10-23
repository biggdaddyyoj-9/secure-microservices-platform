public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs    = ["10.0.3.0/24", "10.0.4.0/24"]
availability_zones      = ["us-east-1a", "us-east-1b"]
region                  = "us-east-1"

node_group_config = {
  instance_types = ["t3.micro"]  # ✅ Free Tier eligible
  desired_size   = 2
  max_size       = 3
  min_size       = 1
}
