output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "eks_subnet_ids" {
  value = aws_subnet.eks[*].id
}

output "alb_dns_name" {
  description = "브라우저로 접속할 ALB 주소"
  value       = aws_lb.alb.dns_name
}

output "pipeline_bucket" {
  value = aws_s3_bucket.pipeline_bucket.bucket
}

output "nat_gateway_public_ip" {
  value = aws_eip.nat.public_ip
}

output "bastion_public_ip" {
  description = "ssh -J ec2-user@<이 값> ec2-user@<ASG 인스턴스 사설 IP>"
  value       = aws_instance.bastion.public_ip
}
