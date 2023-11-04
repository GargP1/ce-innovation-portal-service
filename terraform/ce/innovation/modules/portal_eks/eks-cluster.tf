# Create EKS cluster
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  cluster_name                   = var.cluster_name
  cluster_version                = var.cluster_version
  subnet_ids                     = var.private_subnet_ids
  cluster_enabled_log_types      = var.cluster_enabled_log_types
  create_cloudwatch_log_group    = var.create_cloudwatch_log_group
  version                        = "19.5.1"
  cluster_endpoint_public_access = "true"

  cluster_addons = {
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = module.kms.key_arn
    resources        = ["secrets"]
  }

  aws_auth_roles = [
    {

    },
  ]

  fargate_profiles = {
    "fp-default" = {
      name = "fp-default"
      selectors = [
        {
          namespace = "default"
        },
        {
          namespace = "kube-system"
        }
      ]
      subnet_ids = [var.private_subnet_ids[0], var.private_subnet_ids[1], var.private_subnet_ids[2]]

      tags = {
        Owner = "default"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
    "fp-portal" = {
      name = "portal"
      selectors = [
        {
          namespace = "portal"
        }
      ]
      subnet_ids = [var.private_subnet_ids[0], var.private_subnet_ids[1], var.private_subnet_ids[2]]

      tags = {
        Owner = "default"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
    "fp-external-secrets" = {
      name = "external-secrets"
      selectors = [
        {
          namespace = "external-secrets"
        }
      ]
      subnet_ids = [var.private_subnet_ids[0], var.private_subnet_ids[1], var.private_subnet_ids[2]]

      tags = {
        Owner = "default"
      }

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }

  tags = {
    Product = var.cluster_name
  }

  vpc_id = var.vpc_id
}

resource "null_resource" "create_kubeconfig" {

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}"
  }
  depends_on = [
    module.eks.fargate_profiles
  ]
}

resource "null_resource" "coredns_patch" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
		kubectl patch deployment coredns \
		  --namespace kube-system \
		  --type=json \
		  -p='[{"op": "remove", "path": "/spec/template/metadata/annotations", "value": "eks.amazonaws.com/compute-type"}]'
	EOF
  }
  depends_on = [
    null_resource.create_kubeconfig
  ]
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.1.0"

  aliases               = ["eks/${var.cluster_name}"]
  description           = "eks cluster encryption key"
  enable_default_policy = true
  key_owners            = [data.aws_caller_identity.current.arn]
}
