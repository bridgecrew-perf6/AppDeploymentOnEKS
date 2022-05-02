variable "region" {
  default     = "us-east-1"
  description = "AWS region"
}

variable "cluster_name" {
  default = "dinipere-cluster"
}

variable "vpc" {
  default = "dinipere-vpc"
}

variable "create" {
  description = "Controls if EKS resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

variable "node_group_name" {
  default = "dinipere-node"
}

variable "nodes_sg_name" {
  default = "dinipere-sg"
}
