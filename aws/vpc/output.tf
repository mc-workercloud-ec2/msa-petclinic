output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_ids" {
  value       = aws_subnet.private[*].id
}

output "subnet_db_ids" {
  value       = aws_subnet.db[*].id
}