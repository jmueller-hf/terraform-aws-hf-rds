locals {
  availability_zones = lookup(lookup(var.account_vars, var.environment),var.subnet_type).availability_zones
  security_groups = lookup(lookup(lookup(var.account_vars, var.environment),var.subnet_type).security_groups, var.engine == "aurora-mysql" ? "mysql" : "postgresql")
  instance_class = lookup(lookup(var.account_vars, var.environment).db_instance_sizes, lower(var.instance_size))
  cost_center = lookup(var.cost_centers, var.cost_center)
  cluster_fmt = lower(format("%s%s%s-%s%s",lower(substr(var.environment, 0, 1)),var.subnet_type == "DMZ" ? "e": "i","ae1", lower(local.cost_center.OU), var.cluster_name))
  cluster_id = max(concat([0],[for i in data.aws_rds_clusters.clusters.cluster_identifiers: try(tonumber(element(regex("^${local.cluster_fmt}-(\\d*)-cluster$",i),1)),0)])...) + 1
  cluster_name = format("%s-%02s-cluster", local.cluster_fmt, random_integer.cluster_id.result)
}

data "aws_rds_clusters" "clusters" {}

resource "random_integer" "cluster_id" {
  min = local.cluster_id
  max = local.cluster_id
  lifecycle {
    ignore_changes = [
      min,
      max,
    ]
  }
}

resource "random_password" "master_password" {
  length           = 16
  min_lower        = 1
  min_upper        = 1
  min_special      = 1
  override_special = "!#$%&?"
}

resource "aws_rds_cluster" "cluster" {
  cluster_identifier      = local.cluster_name
  engine                  = var.engine
  engine_version          = var.engine_version
  availability_zones      = local.availability_zones
  database_name           = var.database_name
  master_username         = var.master_username
  master_password         = "${random_password.master_password.result}"
  db_subnet_group_name    = lower(var.subnet_type)
  vpc_security_group_ids  = [local.security_groups]
  skip_final_snapshot     = var.skip_final_snapshot
  backup_retention_period = var.backup_retention_period
  copy_tags_to_snapshot   = var.copy_tags_to_snapshot
  lifecycle {
    ignore_changes = [
      availability_zones
    ]
  }
  tags = {
    "Name"                = local.cluster_name
    "Service Role"        = "RDS DB Cluster"
  }
}

resource "aws_rds_cluster_instance" "instance" {
  count                   = var.instance_count
  identifier              = "${local.cluster_name}-instance-${format("%02d", count.index + 1)}"
  cluster_identifier      = aws_rds_cluster.cluster.id
  instance_class          = local.instance_class
  engine                  = aws_rds_cluster.cluster.engine
  engine_version          = aws_rds_cluster.cluster.engine_version
  db_subnet_group_name    = aws_rds_cluster.cluster.db_subnet_group_name
  tags = {
    "Name"                = "${local.cluster_name}-instance-${format("%02d", count.index + 1)}"
    "Service Role"        = "RDS DB Instance"
  }
}
