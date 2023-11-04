# Main entrypoint
terraform {
  backend "s3" {
    bucket         = "alpha-us-east-2"
    key            = "dev/portal/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-state"
  }
  required_version = ">=1.1.0"
}

# Retrieving account_id
data "aws_caller_identity" "current" {}

# Local variables
locals {

  ## EKS Cluster specific variables
  account_id                        = data.aws_caller_identity.current.account_id
  region                            = "us-east-2"
  cluster_name                      = "dev-portal-ce-innv-cluster"
  vpc_cidr                          = "10.0.0.0/16"
  public_subnet_cidrs               = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
  private_subnet_cidrs              = ["10.0.12.0/22", "10.0.16.0/22", "10.0.20.0/22"]
  db_subnet_cidrs                   = ["10.0.24.0/22", "10.0.28.0/22", "10.0.32.0/22"]
  enable_vpc_flow_log               = true
  flow_log_max_aggregation_interval = 60
  vpc_flow_logs_retention_in_days   = 30
  project_name                      = "portal"
  fqdn                              = "portal.garpunee.myinstance.com" ## Fully Qualified domain name/URL through which you want to access your service
  zone_id                           = "ZX2H9WXM088TM"
  acm_cert_arn                      = "arn:aws:acm:us-east-2:412857254796:certificate/4a74f377-7105-4c3a-b326-691569c94fba"


  ## Aurora PostgreSQL  DB
  aurora_postgresql_mode                  = false
  aurora_postgresql_engine                = "aurora-postgresql"
  aurora_postgresql_engine_mode           = "serverless" ## values `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`. Defaults to: `provisioned`
  aurora_postgresql_engine_version        = "11.21"
  aurora_postgresql_database_name         = "PortalDataStore"
  aurora_postgresql_username              = "portal_usr"
  aurora_postgresql_family                = "aurora-postgresql5.7" # DB parameter group
  aurora_postgresql_instance_class        = "db.t3.medium"
  autoscaling_enabled      = true
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 2
  aurora_postgresql_identifier            = "pdm-dev-prtl-tenantagnostic-datastore-cluster"
  aurora_postgresql_create_security_group = false
  aurora_postgresql_apply_immediately     = true
  aurora_postgresql_instances = {
    one = {}
  }

  aurora_postgresql_iam_database_authentication_enabled = "false"
  aurora_postgresql_password                            = ""
  aurora_postgresql_kms_key_id                          = ""      ## The ARN for the KMS encryption key. If creating an encrypted replica
  aurora_postgresql_backup_retention_period             = 1       ## The days to retain backups for 1 to 35 days
  aurora_postgresql_create_db_parameter_group           = "false" ## Whether to create a database parameter group
  aurora_postgresql_enabled_cloudwatch_logs_exports     = []      ## List of log types to enable for exporting to CloudWatch logs.Valid values (depending on engine): `audit`, `error`, `general`, `slowquery`, `postgresql`

  tags = {
    symplr-application  = "Provider Portal"
    symplr-environment  = "dev"
    symplr-owner  =  "tfabiyi@symplr.com "
    symplr-portfolio  = "pdm"
    symplr-product  = "Provider Portal"
    symplr-resource-name  = "pdm-stage-prtl-datastore-cluster"
    symplr-source-code-url  = "url"
    symplr-sprintteam = "Prog-EngPDM-TeamCerberus@symplr.com"
  }
}

# Providers
provider "aws" {
  region = local.region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# portal VPC terraform module
module "portal_vpc" {
  source                            = "../ce/innovation/modules/portal_vpc"
  account_id                        = local.account_id
  region                            = local.region
  cluster_name                      = local.cluster_name
  vpc_cidr                          = local.vpc_cidr
  public_subnet_cidrs               = local.public_subnet_cidrs
  private_subnet_cidrs              = local.private_subnet_cidrs
  db_subnet_cidrs                   = local.db_subnet_cidrs
  enable_vpc_flow_log               = local.enable_vpc_flow_log
  flow_log_max_aggregation_interval = local.flow_log_max_aggregation_interval
  vpc_flow_logs_retention_in_days   = local.vpc_flow_logs_retention_in_days

}

# portal EKS terraform module
module "portal_eks" {

  source                      = "../ce/innovation/modules/portal_eks"
  cluster_name                = local.cluster_name
  cluster_enabled_log_types   = ["audit", "api", "authenticator"]
  create_cloudwatch_log_group = true
  cluster_version             = "1.28"
  account_id                  = local.account_id
  region                      = local.region
  project_name                = local.project_name

  fqdn = local.fqdn

  vpc_id             = module.portal_vpc.vpc_id
  private_subnet_ids = module.portal_vpc.private_subnets

  cert-arn = local.acm_cert_arn

}

# portal RDS Aurora PotgreSQL
module "portal_rds" {

  source                              = "../ce/innovation/modules/portal_rds"
  engine         = local.aurora_postgresql_engine
  engine_mode    = local.aurora_postgresql_engine_mode
  engine_version = local.aurora_postgresql_engine_version
  instance_class = local.aurora_postgresql_instance_class
  autoscaling_enabled      = local.autoscaling_enabled
  autoscaling_min_capacity = local.autoscaling_min_capacity
  autoscaling_max_capacity = local.autoscaling_max_capacity
  db_name        = local.aurora_postgresql_database_name
  username       = local.aurora_postgresql_username
  family         = local.aurora_postgresql_family
  #major_engine_version                = local.aurora_postgresql_major_engine_version
  iam_database_authentication_enabled = local.aurora_postgresql_iam_database_authentication_enabled
  password                            = local.aurora_postgresql_password
  kms_key_id                          = local.aurora_postgresql_kms_key_id
  backup_retention_period             = local.aurora_postgresql_backup_retention_period
  create_db_parameter_group           = local.aurora_postgresql_create_db_parameter_group
  enabled_cloudwatch_logs_exports     = local.aurora_postgresql_enabled_cloudwatch_logs_exports
  identifier                          = local.aurora_postgresql_identifier
  create_security_group               = local.aurora_postgresql_create_security_group
  instances                           = local.aurora_postgresql_instances
  apply_immediately                   = local.aurora_postgresql_apply_immediately

  vpc_id        = module.portal_vpc.vpc_id
  vpc_cidr      = local.vpc_cidr
  db_subnet_ids = module.portal_vpc.database_subnets
 
  tags = local.tags
}

# portal ACM and Route53 terraform module
#module "portal_r53" {

#  source = "../ce/innovation/modules/portal_acm_r53"

#  fqdn    = local.fqdn
#  zone_id = local.zone_id
#  region  = local.region
#}

# Outputs
output "account_id" {
  value = local.account_id
}

output "region" {
  value = local.region
}

output "URL" {
  value = "https://${local.fqdn}"
}

output "Record" {
  value = local.fqdn
}
