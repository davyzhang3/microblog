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
  version = "17.22.0"
  # insert the 7 required variables here

  cluster_version = "1.21"
  cluster_name    = "EKS-lab"
  # get vpc_id, subnets from VPC module
  vpc_id          = module.EKS-lab-vpc.vpc_id
  subnets         = module.EKS-lab-vpc.private_subnets

  tags = {
      environment = "lab"
      application = "mongodb"
  }

  worker_groups = [
      {
          # instance type, name of worker groups, number of instances
          instance_type = "t2.small"
          name = "EKS-Lab-Node_Group"
          asg_desired_capacity = 3
      }
  ]
}

output "eks-cluster-id" {
  value = module.eks.cluster_id
}
