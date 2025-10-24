data "aws_ssm_parameter" "eks_ami" {
  name   = "/aws/service/eks/optimized-ami/1.27/amazon-linux-2/recommended/image_id"
  region = var.region
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix   = "${var.cluster_name}-lt"
  image_id      = data.aws_ssm_parameter.eks_ami.value
  instance_type = "t3.micro"

  user_data = base64encode(<<-EOF
  #!/bin/bash
  /etc/eks/bootstrap.sh ${var.cluster_name}
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.cluster_name}-node"
      Environment = var.environment
      Owner       = "John"
    }
  }
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = var.tags
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-default"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.node_group_config.desired_size
    max_size     = var.node_group_config.max_size
    min_size     = var.node_group_config.min_size
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.cluster_name}-default-node-group"
    }
  )

  depends_on = [aws_eks_cluster.this]
}