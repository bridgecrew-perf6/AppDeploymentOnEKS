data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_elb" "demo" {
  name = local.lb_name
}

data "aws_availability_zones" "available" {}
