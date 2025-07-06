module "rds_module" {
  source = "./modules/rds"

  project_name = "project-4-rds-module"

  # RDS Configuration Variables already have default values. (See rds-variables.tf)

  rds_credentials = {
    username = "steveadmin" # username must contain at least 8 characters and must only contain alphanumeric characters.
    password = "abc-+123_?"
  }

  # The subnet and security group resources have to be created first before populating these argument lists with the respective subnet- 
  # -and security group IDs.
  subnet_ids             = [/*Subnet IDs here*/]
  vpc_security_group_ids = [/*Security Group IDs here*/]
}