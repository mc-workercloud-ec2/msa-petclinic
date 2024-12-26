output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value       = aws_subnet.private[*].id
}

output "subnet_db_ids" {
  value       = aws_subnet.db[*].id
}
output "s3_endpoint" {
  value = aws_vpc_endpoint.s3.id
}