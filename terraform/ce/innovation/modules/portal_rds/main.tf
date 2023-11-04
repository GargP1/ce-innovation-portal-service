resource "random_password" "master" {
  length  = 20
  special = false
}

module "cluster" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name = var.identifier

  engine            = var.engine
  engine_mode       = var.engine_mode
  engine_version    = var.engine_version
  instance_class    = var.instance_class
  instances         = var.instances
  apply_immediately = var.apply_immediately

  database_name   = var.db_name
  master_username = var.username

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  vpc_security_group_ids = [aws_security_group.db_sg.id]

  kms_key_id              = var.kms_key_id
  backup_retention_period = var.backup_retention_period
  #create_db_option_group          = var.create_db_option_group
  create_db_parameter_group       = var.create_db_parameter_group
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  # DB subnet group
  create_db_subnet_group = true
  subnets                = var.db_subnet_ids

  # DB parameter group
  db_parameter_group_family = var.family

  create_security_group = var.create_security_group

  # Serverless v1 clusters do not support managed master user password
  manage_master_user_password = false
  master_password             = random_password.master.result

  scaling_configuration = {
    auto_pause               = true
    min_capacity             = var.autoscaling_min_capacity
    max_capacity             = var.autoscaling_max_capacity
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  tags = var.tags
}

resource "aws_security_group" "db_sg" {
  name        = "${var.engine}-db-sg"
  description = "DB security group"
  vpc_id      = var.vpc_id

  tags = {
    Deployment = var.db_name
  }
}

# DB Connection 
resource "aws_security_group_rule" "sg_rule" {
  type              = "ingress"
  from_port         = "5432"
  to_port           = "5432"
  protocol          = "tcp"
  security_group_id = aws_security_group.db_sg.id
  cidr_blocks       = [var.vpc_cidr]
}
