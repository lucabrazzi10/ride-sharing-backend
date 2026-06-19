module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  # Updated v21.0 argument syntax
  name               = "rideshare-${var.environment}-cluster"
  kubernetes_version = "1.33"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets

  # Updated v21.0 argument syntax
  endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true
  endpoint_private_access = true
  eks_managed_node_groups = {
    standard_node_group = {
      instance_types = ["t3.medium"]
      min_size       = 2
      max_size       = 3
      desired_size   = 2
    }
  }

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}