# Load Balancer Controllers supports the ingress/ALB object

module "load_balancer_controller" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-lb-controller.git?ref=0.7.0"

  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn
  cluster_name                     = var.cluster_name
  helm_chart_version               = "1.4.1"
  settings = {
    vpcId  = "${var.vpc_id}"
    region = "${var.region}"
  }

  depends_on = [null_resource.create_kubeconfig]
}
