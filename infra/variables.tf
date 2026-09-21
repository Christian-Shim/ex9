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
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
}

variable "eks_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.20.0/24", "10.0.21.0/24", "10.0.22.0/24"]
}

variable "key_name" {
  description = "키페어 이름"
  type        = string
  default     = "std12-key"
}



variable "cluster_name" {
  description = "추후 생성할 EKS 클러스터 이름. 서브넷 태그(kubernetes.io/cluster/...)에 미리 사용되므로, 나중에 EKS 리소스를 만들 때 이 이름과 반드시 일치시켜야 함"
  type        = string
  default     = "std12-eks-cluster"
}

variable "eks_version" {
  description = "EKS Kubernetes 버전"
  type        = string
  default     = "1.36"
}

variable "node_instance_type" {
  description = "EKS 노드 인스턴스 타입"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 2
}
