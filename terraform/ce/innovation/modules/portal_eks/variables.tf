#Variables for AWS account_id and azs

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

variable "cluster_name" {
  description = "EKS Cluster Name"
}

variable "cluster_version" {
  description = "EKS Cluster Version"
}

variable "cluster_enabled_log_types" {
  description = "Functional Kubernetes logging for different components"
}

variable "create_cloudwatch_log_group" {
  description = "Cloudwatch logs group for EKS cluster"
}

variable "region" {
  description = "AWS default region"
}

variable "account_id" {
  description = "AWS Account ID"
}

variable "vpc_id" {
  description = "EKS's VPC"
}

variable "private_subnet_ids" {
  description = "Private subnets for EKS cluster and node group"
}

variable "project_name" {
  description = "Project Name"
}

variable "fqdn" {
  description = "domain_name/URL for formio service"
}

variable "cert-arn" {
  description = "ACM cert ARN"
}

