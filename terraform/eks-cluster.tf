# the process of creating a EKS cluster takes about 15 mins
provider "kubernetes" {
    host = data.aws_eks_cluster.EKS-lab-cluster.endpoint
    token = data.aws_eks_cluster_auth.EKS-lab-cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.EKS-lab-cluster.certificate_authority[0].data)
}

# provide or query aws_eks_cluster with this id
data "aws_eks_cluster" "EKS-lab-cluster"{
  name = module.eks.cluster_id
}

# give an object which includes token
data "aws_eks_cluster_auth" "EKS-lab-cluster"{
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"
  # insert the 7 required variables here

  cluster_version = "1.21"
  cluster_name    = "EKS-Lab"
  # get vpc_id, subnets from VPC module
  vpc_id          = module.EKS-Lab-vpc.vpc_id
  subnet_ids      = module.EKS-Lab-vpc.private_subnets

  tags = {
      environment = "lab"
      application = "myApp"
  }


    # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    #blue = {}
    green = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t2.small"]
    }
  }
}

output "eks-cluster-id" {
  value = module.eks.cluster_id
}
