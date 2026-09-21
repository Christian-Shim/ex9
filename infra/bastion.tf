# ASG 인스턴스는 프라이빗 서브넷에 배치 (asg.tf 의 vpc_zone_identifier 가 참조)
data "aws_subnets" "target_subnets" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-private-*"]
  }

  depends_on = [aws_subnet.private]
}

# 프라이빗 인스턴스 SSH 접속용 Bastion (EIP 는 NAT 용 1개만 사용하므로 자동 할당 퍼블릭 IP 사용)
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  key_name                    = local.key_name
  subnet_id                   = aws_subnet.public[0].id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "${local.tag_header}bastion"
  }
}
