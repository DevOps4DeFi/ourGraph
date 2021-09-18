locals {
  use_rds = var.rds_instance_type != null && var.rds_storage_size != null
  use_rds_count = local.use_rds == null ? 0:1
}


resource "random_pet" "db_password" {
  length = 5
}
resource "aws_ssm_parameter" "db_password" {
  name = "${var.ssm_root}/ourGraph/${var.app_name}/-rds_password"
  type = "String"
  value = random_pet.db_password.id
  lifecycle {ignore_changes = [value]}
}

resource "aws_security_group" "graph-node-db" {
  count = local.use_rds_count
  name_prefix = "ourGraphDB"
  vpc_id = data.aws_vpc.vpc.id
  ingress {
    from_port = 5432
    protocol = "TCP"
    to_port = 5432
    cidr_blocks = [data.aws_vpc.vpc.cidr_block]
    #security_groups = [aws_security_group.graph-node.id] ## TODO move here for more security/harder debuggingi
  }
}

module "rds" {
  count= local.use_rds_count
  source  = "terraform-aws-modules/rds/aws"
    version = "2.34.0"
    # insert the 29 required variables here


  identifier = "${var.app_name}-db"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version = "13.3"
  family               = "postgres13" # DB parameter group
  major_engine_version = "13"         # DB option group
  instance_class       = var.rds_instance_type

  allocated_storage     = 20
  max_allocated_storage = var.rds_storage_size
  storage_encrypted     = false

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  name     = "graphprotocol"
  username = "graphnode"
  password = aws_ssm_parameter.db_password.value
  port     = 5432

  multi_az               = false
  subnet_ids             = var.subnet_ids ## Used [0] as this is also where we run nodes, but if networking isn't a big deal could be multiple subnets in the az
  vpc_security_group_ids = [aws_security_group.graph-node-db[0].id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  publicly_accessible = false
  backup_retention_period = 14
  skip_final_snapshot     = false
  deletion_protection     = false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role = var.rds_monitoring_role_arn == null
  monitoring_role_arn = var.rds_monitoring_role_arn
  monitoring_interval                   = 60

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
  tags = merge(local.tags, {Name = "${var.app_name}-db"})

  db_option_group_tags = merge(local.tags, {Name = "${var.app_name}-db"})
  db_parameter_group_tags = merge(local.tags, {Name = "${var.app_name}-db"})
  db_subnet_group_tags =  merge(local.tags, {Name = "${var.app_name}-db"})
}
