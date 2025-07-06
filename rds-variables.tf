#########################
# General Variables
#########################
variable "project_name" {
  description = "The name of the project. Used to name some of our resources."
  type        = string
}

##############################
# RDS Variables
##############################
variable "rds_configuration" {
  description = <<-EOT
  Our RDS configuration variables which must all fall under free-tier.
    1.) rds_instance_class must be "db.t3.micro".
    2.) rds_allocated_storage must be between 5GB and 10GB.
    3.) rds_engine must be "postgres-latest" or "postgres-14".
  EOT

  type = object({
    rds_instance_class    = string
    rds_allocated_storage = number
    rds_engine            = string
  })

  default = {
    rds_instance_class    = "db.t3.micro"
    rds_allocated_storage = 10
    rds_engine            = "postgres-latest"
  }

  validation {
    condition     = contains(["db.t3.micro"], var.rds_configuration.rds_instance_class)
    error_message = "RDS instance class is invalid or does not fall under free-tier. Only \"db.t3.micro\" is allowed."
  }

  validation {
    condition     = 5 <= var.rds_configuration.rds_allocated_storage && var.rds_configuration.rds_allocated_storage <= 10
    error_message = "RDS allocated storage is invalid or does not fall under free-tier. Allocated storage must be between 5GB and 10GB."
  }

  validation {
    condition     = contains(["postgres-latest", "postgres-14"], var.rds_configuration.rds_engine)
    error_message = "RDS engine is invalid or does not fall under free-tier. Engine must be \"postgres-latest\", \"postgres-14\"."
  }
}

variable "rds_credentials" {
  description = "Our RDS username and password. The password must follow a set of rules."
  sensitive   = true
  type = object({
    username = string
    password = string
  })

  validation {
    condition = (
      # "^$" ensures that only the characters within the list [] are allowed. {6,} means the length must be at least 6 characters long.
      length(regexall("^[a-zA-Z0-9+_?-]{8,}$", var.rds_credentials.password)) >= 1
      && length(regexall("[a-zA-Z]+", var.rds_credentials.password)) >= 1
      && length(regexall("[0-9]+", var.rds_credentials.password)) >= 1
    )
    error_message = <<-EOT
    Password must follow the following rules: 
      1.) Be at least 8 characters long.
      2.) Contain at least one character (a-z, A-Z).
      3.) Contain at least one number (0-9).
      4.) Symbols are allowed but only the following: "+", "-", "?", and "_".
    EOT
  }
}

#######################
# Networking Variables
#######################
variable "subnet_ids" {
  description = "A list of subnet IDs that our RDS instance can be deployed in."
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "A list of VPC security group IDs that our RDS instance can use."
  type        = list(string)
}