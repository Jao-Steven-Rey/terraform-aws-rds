locals {
  rds_engine = {
    postgres-latest = { # Obtained from "var.rds_configuration.rds_engine"
      engine  = "postgres"
      version = "17.4"
      family  = "postgres17"
    }
    postgres-14 = {
      engine  = "postgres"
      version = "14.18"
      family  = "postgres14"
    }
  }
}

resource "aws_db_subnet_group" "for_rds" {
  name       = var.project_name
  subnet_ids = var.subnet_ids # Subnet IDs within subnet group must cover more than 1 availability zone.

  tags = {
    Name = var.project_name
  }
}

# A parameter group acts as a container for engine configuration values that can be applied to one or more DB instances.
resource "aws_db_parameter_group" "for_rds" {
  name   = var.project_name
  family = local.rds_engine[var.rds_configuration.rds_engine].family # Sets the database engine version. In this case, it's postgres17.

  # This parameter block is used to configure the Postgres database we are running. The parameters inside should be accepted by Postgres.
  parameter {
    name  = "log_connections" # Specifies the parameter to change. In PostgreSQL, log_connections control connection logging.
    value = "1"               # Sets the value of log_connections to 1 meaning "on", allowing logging for every successful connection to database.
  }
}

# WARNING! Creation of RDS instance takes around 5 minutes.
resource "aws_db_instance" "default" {
  identifier           = var.project_name
  instance_class       = var.rds_configuration.rds_instance_class
  allocated_storage    = var.rds_configuration.rds_allocated_storage
  engine               = local.rds_engine[var.rds_configuration.rds_engine].engine
  engine_version       = local.rds_engine[var.rds_configuration.rds_engine].version
  username             = var.rds_credentials.username
  password             = var.rds_credentials.password
  db_subnet_group_name = aws_db_subnet_group.for_rds.name
  vpc_security_group_ids = var.vpc_security_group_ids # MUST BE A LIST
  publicly_accessible = false # For security purposes
  skip_final_snapshot = true  # Since we don't want to keep snapshots after terminating the RDS instance
}