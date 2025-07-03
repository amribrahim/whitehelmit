provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  
  env              = var.environment
  vpc_cidr_block   = var.vpc_cidr
  azs              = var.availability_zones
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

module "eks" {
  source = "./modules/eks"
  
  env         = var.environment
  eks_name    = var.cluster_name
  eks_version = var.cluster_version
  subnet_ids  = module.vpc.private_subnets
  
  node_groups = var.node_groups
  
  depends_on = [module.vpc]
}

