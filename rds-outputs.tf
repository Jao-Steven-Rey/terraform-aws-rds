output "rds_instance_arn" {
  description = "Our RDS instance's ARN."
  value       = aws_db_instance.default.arn
}

output "rds_instance_id" {
  description = "Our RDS instance's ID."
  value       = aws_db_instance.default.id
}

output "rds_instance_address" {
  description = "Our RDS instance's hostname."
  value       = aws_db_instance.default.address
}

output "rds_instance_port" {
  description = "The port to our RDS instance."
  value       = aws_db_instance.default.port
}

output "rds_instance_endpoint" {
  description = "The endpoint to our RDS instance in address:port format."
  value       = aws_db_instance.default.endpoint
}