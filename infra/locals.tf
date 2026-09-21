locals {
  key_name = var.key_name

  # 리소스 이름 접두사. 예) std12-ex-  (끝에 "-" 포함)
  tag_header = (var.owner != "" && var.environment != "") ? "${var.owner}-${var.environment}-" : (
    (var.owner != "") ? "${var.owner}-" : ""
  )

  vpc_id              = aws_vpc.vpc.id
  ami_id              = data.aws_ami.al2023.id
  security_groups_ids = [aws_security_group.web.id, aws_security_group.ssh.id]
}

# Amazon Linux 2023 최신 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
