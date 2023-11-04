# External Secret to support secrets from secret manager

module "external_secrets" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-external-secrets.git?ref=2.2.0"

  enabled = true

  cluster_name                     = var.cluster_name
  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  #secrets_aws_region               = var.region

  depends_on = [null_resource.create_kubeconfig]

}
