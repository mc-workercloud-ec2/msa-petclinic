data "aws_acm_certificate" "issued" {
  domain   = "*.${var.domain}"
  statuses = ["ISSUED"]
}

module "vpc" {
  source       = "../aws/vpc"
  cluster_name = "${var.cluster_name}-${var.environment}"
  environment  = var.environment
}

module "rds" {
  source      = "../aws/rds"
  dbname      = var.dbname
  subnet_ids  = module.vpc.subnet_db_ids
  dbuser      = var.dbuser
  dbpassword  = var.dbpass
  vpc_id      = module.vpc.vpc_id
  environment = var.environment
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~>20.31"

  cluster_name    = "${var.cluster_name}-${var.environment}"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.subnet_ids


  cluster_compute_config = {
    enabled    = true
    node_pools = ["general-purpose"]
  }

  tags = {
    Environment = var.environment
  }
  
}
module "s3" {
    source       = "../aws/s3"
    s3_endpoint  = module.vpc.s3_endpoint
    environment  = var.environment
    oidc         = module.eks.oidc_provider
    oidc_arn     = module.eks.oidc_provider_arn
}


module "helm" {
  source = "../kubernetes/helm"
  loki_arn = module.s3.loki_role_arn
  loki_bucket = module.s3.loki_bucket
}


data "aws_route53_zone" "main" {
  name = "${var.domain}."
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = module.eks.cluster_name
  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn



  enable_kube_prometheus_stack          = true
  enable_argocd                         = true
  enable_metrics_server                 = true
  enable_external_dns                   = true
  enable_cert_manager                   = true
  cert_manager_route53_hosted_zone_arns = [data.aws_route53_zone.main.arn]
  external_dns_route53_zone_arns        = [data.aws_route53_zone.main.arn]

  argocd = {
    name          = "argocd"
    chart_version = "7.7.11"
    repository    = "https://argoproj.github.io/argo-helm"
    namespace     = "argocd"
    values = [templatefile("${path.module}/values/argocd.yaml", {
      domain       = var.domain,
      tls_cert_arn = data.aws_acm_certificate.issued.arn
    })]
  }

  kube_prometheus_stack = {
    name          = "kube-prometheus-stack"
    chart_version = "67.4.0"
    repository    = "https://prometheus-community.github.io/helm-charts"
    namespace     = "kube-prometheus-stack"
    values = [templatefile("${path.module}/values/kube-prometheus-stack.yaml", {
      domain       = var.domain,
      tls_cert_arn = data.aws_acm_certificate.issued.arn
    })]
  }

  tags = {
    Environment = var.environment
  }
  #   depends_on = [ module.kubernetes_resources ]
}




//////////////// CRD //////////////////

resource "kubernetes_manifest" "alb_ingress_class_params" {
  manifest = {
    "apiVersion" = "eks.amazonaws.com/v1"
    "kind"       = "IngressClassParams"
    "metadata" = {
      "name" = "alb"
    }
    "spec" = {
      "scheme" = "internet-facing"
    }
  }
}

resource "kubernetes_manifest" "alb_ingress_class" {
  manifest = {
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "IngressClass"
    "metadata" = {
      "name" = "alb"
      "annotations" = {
        "ingressclass.kubernetes.io/is-default-class" = "true"
      }
    }
    "spec" = {
      "controller" = "eks.amazonaws.com/alb"
      "parameters" = {
        "apiGroup" = "eks.amazonaws.com"
        "kind"     = "IngressClassParams"
        "name"     = "alb"
      }
    }
  }
}

resource "kubernetes_manifest" "ebs_storage_class" {
  manifest = {
    "apiVersion" = "storage.k8s.io/v1"
    "kind"       = "StorageClass"
    "metadata" = {
      "name" = "auto-ebs-sc"
      "annotations" = {
        "storageclass.kubernetes.io/is-default-class" = "true"
      }
    }
    "provisioner"       = "ebs.csi.eks.amazonaws.com"
    "volumeBindingMode" = "WaitForFirstConsumer"
    "parameters" = {
      "type"      = "gp3"
      "encrypted" = "true"
    }
  }
}

////////////////////////////////////////

module "ecr" {
  source = "../aws/ecr"
  container_name = "ec2-team"
}
