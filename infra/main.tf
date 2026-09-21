# ################################################################################
# 테라폼 기본 설정
# ================================================================================
# 키페어 / AMI / 보안그룹 / 서브넷ID / 
variable "key_name" {
  description = "키페어 이름"
  type        = string
  default     = "std12-key"
}

variable "owner" {
  description = "사용자 계정 이름"
  type        = string
  default     = "std12"
}

variable "environment" {
  description = "프로젝트 역할 구분"
  type        = string
  default     = "ex" # dev / db / op / ex / lab / 
}

locals {
  key_name = var.key_name
  tag_header = (var.owner != "" && var.environment != "") ? "${var.owner}-${var.environment}-" : (
    (var.owner != "") ? "${var.owner}-" : ""
  )
  vpc_id = data.aws_vpc.vpc.id
}

# VPC ID
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["${local.tag_header}vpc"]
  }
}


output "information" {
  value = local.vpc_id
}










