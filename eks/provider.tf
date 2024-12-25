terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.8.1"
    }
  }

  backend "s3" {
    dynamodb_table = "ec2-team-eks-2024-backend"
    key            = "dev/terraform.tfstate"
    bucket         = "ec2-team-eks-2024-backend"
    encrypt        = true
    region         = "ap-northeast-2"
  }
  
}

provider "kubernetes" {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", "${var.cluster_name}-${var.environment}"]
    command     = "aws"
  }
}
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1"
    args        = ["eks", "get-token", "--cluster-name", "${var.cluster_name}-${var.environment}"]
    command     = "aws"
  }
}
}