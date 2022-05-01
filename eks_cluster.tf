module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = " >= 12.2.1"
  cluster_name                    = var.cluster_name
  cluster_version                 = "1.20"
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  vpc_id                          = module.vpc.vpc_id
}



/*workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.micro"
      additional_userdata           = "node"
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
      asg_desired_capacity          = 2
    },

  ]
}


#resource "kubernetes_config_map" "aws_auth" {
   = data.manage_aws_auth_configmap
}*/

resource "kubernetes_config_map" "aws_auth" {
  count = var.create ? 1 : 0

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

}
