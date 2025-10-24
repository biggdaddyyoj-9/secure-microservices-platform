# EKS Cluster Role
resource "aws_iam_role" "eks_cluster" {                              # Creates an IAM role for the EKS control plane
  name = "eks-cluster-role"                                          # Sets the name of the IAM role
                                                                     
  assume_role_policy = jsonencode({                                  # Defines the trust policy for EKS to assume this role
    Version = "2012-10-17"                                           # IAM policy version
    Statement = [{                                                   # Policy statement block
      Effect = "Allow"                                               # Allows the action defined below
      Principal = {                                                  # Specifies the trusted service
        Service = "eks.amazonaws.com"                                # EKS control plane will assume this role
      }
      Action = "sts:AssumeRole"                                      # Grants permission to assume the role
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {  # Attaches the AmazonEKSClusterPolicy to the cluster role
  role       = aws_iam_role.eks_cluster.name                                     # References the cluster IAM role
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"                  # Grants EKS control plane permissions to manage cluster resources
}

# EKS Node Group Role
resource "aws_iam_role" "eks_node" {                                 # Creates an IAM role for EKS worker nodes
  name = "eks-node-role"                                             # Sets the name of the IAM role

  assume_role_policy = jsonencode({                                  # Defines the trust policy for EC2 to assume this role
    Version = "2012-10-17"                                           # IAM policy version
    Statement = [{                                                   # Policy statement block
      Effect = "Allow"                                               # Allows the action defined below
      Principal = {                                                  # Specifies the trusted service
        Service = "ec2.amazonaws.com"                                # EC2 instances will assume this role
      }
      Action = "sts:AssumeRole"                                      # Grants permission to assume the role
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKSWorkerNodePolicy" {  # Attaches the AmazonEKSWorkerNodePolicy to the node role
  role       = aws_iam_role.eks_node.name                                        # References the node IAM role
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"              # Grants permissions for node lifecycle and cluster registration
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEC2ContainerRegistryReadOnly" {  # Attaches read-only access to ECR for pulling container images
  role       = aws_iam_role.eks_node.name                                                 # References the node IAM role
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"               # Grants permission to pull images from ECR
}

resource "aws_iam_role_policy_attachment" "eks_node_AmazonEKS_CNI_Policy" {  # Attaches the CNI policy for pod networking
  role       = aws_iam_role.eks_node.name                                  # References the node IAM role
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"              # Grants permission to manage ENIs and networking for pods
}
