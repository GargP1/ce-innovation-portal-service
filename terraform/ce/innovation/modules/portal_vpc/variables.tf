# AWS account
variable "account_id" {
  type = string
}

# AWS region
variable "region" {
  type = string
}

# EKS Cluster Name
variable "cluster_name" {
  type = string
}

# VPC CIDR
variable "vpc_cidr" {
  type = string
}

# Private Subnet CIDRs
variable "private_subnet_cidrs" {
  type = list(string)
}

# Public Subnet CIDRs
variable "public_subnet_cidrs" {
  type = list(string)
}

# Databse Subnet CIDRs
variable "db_subnet_cidrs" {
  type = list(string)
}

# VPC Flow logs flag
variable "enable_vpc_flow_log" {
  type = bool
}

# VPC Flow logs Retention in days
variable "vpc_flow_logs_retention_in_days" {
  type = number
}

# VPC Flow logs flag
variable "flow_log_max_aggregation_interval" {
  type = number
}
