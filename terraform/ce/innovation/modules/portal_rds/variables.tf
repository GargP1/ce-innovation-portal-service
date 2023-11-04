variable "engine" {
  type = string
}

variable "engine_mode" {
  type = string
}

variable "engine_version" {
  type = string
}


variable "instance_class" {
  type = string
}

variable "db_name" {
  type = string
}


variable "identifier" {
  type = string
}

variable "apply_immediately" {
  type = string
}

variable "family" {
  type = string
}

variable "username" {
  type = string
}

variable "db_subnet_ids" {
  description = "DB subnet ids "
}

variable "instances" {
  description = "RDS Instances"
}

variable "iam_database_authentication_enabled" {
  description = "IAM DB auth"
}

variable "create_security_group" {
  description = "create security group"
}

#variable "allocated_storage" {
#  description = "allocated storage"
#}

variable "password" {
  description = "Password for the master DB user."
}


variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If creating an encrypted replica"
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
}

variable "create_db_parameter_group" {
  description = "Whether to create a database parameter group"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to enable for exporting to CloudWatch logs.Valid values (depending on engine): audit, general, slowquery"
}

variable "vpc_id" {
  description = "VPC-ID"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
}


variable "autoscaling_enabled" {
  description = "Is autoscaling enabled"
}


variable "autoscaling_min_capacity" {
  description = "Autoscaling min capacity"
}


variable "autoscaling_max_capacity" {
  description = "Autoscaling max capacity"
}


variable "tags" {
  description = "tags"
}
