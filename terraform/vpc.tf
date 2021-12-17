terraform {
    // reference: https://www.terraform.io/language/settings/backends/s3
    // you have to create a bucket mannually in AWS S3 before applying this script
    backend "s3" {
        bucket = "weclouddata-devops-microblog-2"
        key = "microblog/terraform.tfstate"
        region = "us-east-1"
        shared_credentials_file = "/Users/daweizhang/.aws/config"
        profile = "beamdata-dawei"
    }
    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 3.0"
        }
  }
}
provider "aws" {
    # location of your credential
    shared_credentials_file = "/Users/daweizhang/.aws/config"
    # name of your profile
    profile = "beamdata-dawei"
    # region
    region = "us-east-1"
}

variable vpc_cidr_block {}
variable private_subnet_cidr_blocks {}
variable public_subnet_cidr_blocks {}

# get a list of aws availability zones except ofr us-east-1e, because it doesn't have sufficient resources to create a cluster
data "aws_availability_zones" "azs" {
    exclude_names = ["us-east-1e"]
}

module "EKS-lab-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.10.0"
  # insert the 21 required variables here

  name = "EKS-lab-vpc"
  cidr = var.vpc_cidr_block
  private_subnets = var.private_subnet_cidr_blocks
  public_subnets = var.public_subnet_cidr_blocks
  azs = data.aws_availability_zones.azs.names
  
  # by default there is one NAT gateway per subnet and it is true
  enable_nat_gateway = true
  # all private subnets will route their internet traffic through this single NAT gateway
  single_nat_gateway = true
  # when a instance is created, it will be assigned one public ip address, one private ip address and also one public and private DNS names that resolved to the ip addresses
  enable_dns_hostnames = true

  tags = {
      # this tag is for consumption of Kubernetes Cloud Control Manager
      "kubernetes.io/cluster/EKS-lab" = "shared"
  }

  public_subnet_tags = {
      "kubernetes.io/cluster/EKS-lab" = "shared"
      # elb stands for elastic load balancer. It's an entry point of a cluster from the outside. It's open to external request
      "kubernetes.ip/role/elb" = 1
  }

  private_subnet_tags = {
      "kubernetes.io/cluster/EKS-lab" = "shared"
      # internal elb makes it not open to the public
      "kubernetes.ip/role/internal-elb" = 1
  }
}