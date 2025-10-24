data "aws_ssm_parameter" "eks_ami" {                                                      # Retrieves the latest recommended EKS-optimized AMI ID from AWS SSM
  name   = "/aws/service/eks/optimized-ami/1.27/amazon-linux-2/recommended/image_id"      # AMI path for Kubernetes v1.27 on Amazon Linux 2
  region = var.region               # Specifies the AWS region to use for the AMI lookup                                                      #
}

resource "aws_launch_template" "eks_nodes" {                                              # Defines a reusable EC2 launch template for EKS worker nodes

  name_prefix   = "${var.cluster_name}-lt"                                                # Sets a name prefix for the launch template based on the cluster name 
  image_id      = data.aws_ssm_parameter.eks_ami.value                                    #  # Uses the latest EKS-optimized AMI retrieved from SSM
  instance_type = "t3.micro"                                                              # Selects a Free Tier eligible instance type for cost-effective dev workloads

# Encodes the bootstrap script to register nodes with the EKS cluster
  user_data = base64encode(<<-EOF
  
  #!/bin/bash
  /etc/eks/bootstrap.sh ${var.cluster_name}
EOF
  )
# Starts the shell script
# Runs the EKS bootstrap script using the cluster name
  tag_specifications {                                                                  # Applies tags to EC2 instances created from this launch template
    resource_type = "instance"                                                          # Specifies that the tags apply to EC2 instances
    tags = {
      Name        = "${var.cluster_name}-node"                                          # Sets a readable name tag for the node
      Environment = var.environment                                                     # Tags the instance with the environment (e.g., dev, prod)
      Owner       = "John"                                                              # Indicates resource ownership for accountability
    }
  }
}

resource "aws_eks_cluster" "this" {                                                     # Provisions the EKS control plane (Kubernetes master components)
  name     = var.cluster_name                                                           # Sets the name of the EKS cluster
  role_arn = var.cluster_role_arn                                                       # IAM role that allows EKS to manage AWS resources
  version  = var.kubernetes_version                                                     # Specifies the Kubernetes version to deploy

  vpc_config {                                                                          # Configures networking for the cluster
    subnet_ids = var.subnet_ids                                                         # Assigns subnets for control plane communication
  }

  tags = var.tags                                                                       # Applies consistent tagging for cost tracking and resource management
}

resource "aws_eks_node_group" "default" {                                               # Provisions the default managed node group for the EKS cluster
  cluster_name    = aws_eks_cluster.this.name                                           # Associates the node group with the EKS cluster
  node_group_name = "${var.cluster_name}-default"                                       # Sets a name for the node group
  node_role_arn   = var.node_role_arn                                                   # IAM role that allows nodes to interact with EKS and AWS services
  subnet_ids      = var.subnet_ids                                                      # Places nodes in the specified subnets (typically private)

  scaling_config {                                                                      # Configures autoscaling parameters for the node group
    desired_size = var.node_group_config.desired_size                                   # Number of nodes to launch initially
    max_size     = var.node_group_config.max_size                                       # Maximum number of nodes allowed
    min_size     = var.node_group_config.min_size                                       # Minimum number of nodes to maintain availability
  }

  launch_template {                                                                     # Uses the custom launch template for node configuration
    id      = aws_launch_template.eks_nodes.id                                          # References the launch template ID
    version = "$Latest"                                                                 # Always uses the latest version of the template
  }

  tags = merge(                                                                         # Merges global tags with node group-specific tags
    var.tags,
    {
      "Name" = "${var.cluster_name}-default-node-group"                                 # Adds a descriptive name tag for the node group
    }
  )

  depends_on = [aws_eks_cluster.this]                                                   # Ensures the cluster is created before the node group
}
