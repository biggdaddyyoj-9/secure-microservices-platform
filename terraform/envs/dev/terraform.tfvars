public_subnet_cidrs     = ["10.0.1.0/24", "10.0.2.0/24"]     # Defines two public subnets across AZs for NAT Gateway, IGW, and public-facing resources
private_subnet_cidrs    = ["10.0.3.0/24", "10.0.4.0/24"]     # Defines two private subnets for EKS node placement and internal workloads
availability_zones      = ["us-east-1a", "us-east-1b"]       # Distributes subnets across multiple AZs for high availability and fault tolerance
region                  = "us-east-1"                        # Sets the AWS region for all resources—must match your VPC and EKS cluster

node_group_config = {                                       # Configuration block for EKS node group autoscaling
  instance_types = ["t3.large"]      # Free Tier eligible—cost-efficient for dev workloads and testing
  desired_size   = 5                 # Launches 2 nodes by default—enough to run multiple pods and test HA
  max_size       = 6                 # Allows scaling up to 3 nodes under load—supports burst capacity
  min_size       = 4                 # Ensures at least 1 node is always running—maintains cluster availability
}
