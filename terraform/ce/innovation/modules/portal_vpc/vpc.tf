data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name                                            = "${var.cluster_name}-vpc"
  cidr                                            = var.vpc_cidr
  azs                                             = data.aws_availability_zones.available.names
  private_subnets                                 = var.private_subnet_cidrs
  public_subnets                                  = var.public_subnet_cidrs
  database_subnets                                = var.db_subnet_cidrs
  enable_flow_log                                 = var.enable_vpc_flow_log
  create_flow_log_cloudwatch_log_group            = var.enable_vpc_flow_log
  create_flow_log_cloudwatch_iam_role             = var.enable_vpc_flow_log
  flow_log_max_aggregation_interval               = var.flow_log_max_aggregation_interval
  flow_log_cloudwatch_log_group_retention_in_days = var.vpc_flow_logs_retention_in_days

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}
