module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = " >= 12.2.1"
  cluster_name                    = var.cluster_name
  cluster_version                 = "1.22"
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  vpc_id                          = module.vpc.vpc_id
}



#Nodes in private subnets
resource "aws_eks_node_group" "worker" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.node_group_name}-private"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  tags = {
    Name = "${var.node_group_name}-private"
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.ec2_read_only-AmazonEC2ContainerRegistryReadOnly,
  ]
}


# Nodes in public subnet
resource "aws_eks_node_group" "public" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.node_group_name}-public"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = module.vpc.public_subnets

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  tags = {
    name = "${var.node_group_name}-public"
  }

  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.ec2_read_only-AmazonEC2ContainerRegistryReadOnly,
  ]
}

#Node IAM Role and Policy
resource "aws_iam_role" "eks_nodes" {
  name = "${var.cluster_name}-worker"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "aws_eks_worker_node_policy-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "aws_eks_cni_policy-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "ec2_read_only-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}


#EKS Node security group
resource "aws_security_group" "eks_nodes" {
  name        = var.nodes_sg_name
  description = "Security group for all nodes in the cluster"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name                                        = var.nodes_sg_name
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_security_group_rule" "nodes" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodes_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}






