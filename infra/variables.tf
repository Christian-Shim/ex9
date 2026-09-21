# ------------------------------------------------------------------------------
# 기본 설정
# ------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "리소스 이름 접두사"
  type        = string
  default     = "std12"
}

variable "owner" {
  description = "사용자 계정 이름"
  type        = string
  default     = "std12"
}

variable "environment" {
  description = "프로젝트 역할 구분"
  type        = string
  default     = "ex" # dev / db / op / ex / lab
}

variable "key_name" {
  description = "EC2 키페어 이름 (이미 존재해야 함)"
  type        = string
  default     = "std12-key"
}

# ------------------------------------------------------------------------------
# 네트워크
# ------------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "VPC CIDR 블록"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "사용할 가용영역 목록 (3개)"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "public_subnet_cidrs" {
  description = "퍼블릭 서브넷 CIDR (ALB, EC2)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "프라이빗 서브넷 CIDR"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "eks_subnet_cidrs" {
  description = "EKS 전용 서브넷 CIDR (EKS 클러스터는 만들지 않고 서브넷만 생성)"
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}

# ------------------------------------------------------------------------------
# 보안 / 컴퓨팅
# ------------------------------------------------------------------------------
variable "ssh_allowed_cidrs" {
  description = "SSH(22) 접속을 허용할 CIDR. 실습 후에는 본인 IP/32 로 좁힐 것"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "ASG 인스턴스 타입"
  type        = string
  default     = "t3.small"
}

variable "asg_min_size" {
  type    = number
  default = 1
}

variable "asg_desired_capacity" {
  type    = number
  default = 1
}

variable "asg_max_size" {
  type    = number
  default = 2
}

# ----------------------------------------------------------------------------------
variable "default_version" {
  description = ""
  type        = string
  default     = "latest" # 특정 버전을 지정하고자 할 경우 문자열 형태의 숫자 기재
}
