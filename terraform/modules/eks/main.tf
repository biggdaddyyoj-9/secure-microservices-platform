resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn

  version = var.kubernetes_version

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
    name    = "secure-platform-dev-default"
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
