output "security_group" {
  value       = aws_security_group.services.id
  description = "Id of security Group"
}

output "vpc1" {
  value       = aws_vpc.vpc1.id
  description = "Id of VPC1"
}

output "subnet_public1" {
  value       = aws_subnet.subnet_public1.id
  description = "Id of subnet public 1"
}

output "subnet_private1" {
  value       = aws_subnet.subnet_private1.id
  description = "Id of subnet private 1"
}

output "key_name" {
  value       = aws_key_pair.my_key.key_name
  description = "Name of key pair RSA"
}

output "bucket_domain_name" {
  value       = join("", aws_s3_bucket.terraform-state-storage-s3.*.bucket_domain_name)
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = join("", aws_s3_bucket.terraform-state-storage-s3.*.id)
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = join("", aws_s3_bucket.terraform-state-storage-s3.*.arn)
  description = "Bucket ARN"
}