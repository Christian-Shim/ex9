# Launch Template: Amazon Linux 2023 + nginx (user data)
resource "aws_launch_template" "asg_lt" {
  name_prefix   = "${local.tag_header}lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = local.key_name

  vpc_security_group_ids = [
    aws_security_group.web.id,
    aws_security_group.ssh.id,
  ]

  # 기본 버전 지정 방법 ("latest" 이면 null, 숫자 문자열이면 해당 버전 고정)
  update_default_version = var.default_version == "latest" ? true : false
  default_version        = var.default_version != "latest" ? tonumber(var.default_version) : null

  iam_instance_profile {
    name = aws_iam_instance_profile.node_profile_asg.name
  }

  # 사용자 데이터 생성
  user_data = base64encode(<<-EOF
              #!/bin/bash
              dnf update -y
              # ruby: CodeDeploy서비스 개발 언어, codedeploy-agent 설치를 위해 반드시 필요
              dnf install -y ruby wget docker

              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              cd /tmp
              wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install
              chmod +x ./install
              ./install auto

              systemctl start codedeploy-agent
              systemctl enable codedeploy-agent
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.tag_header}asg-nod-instance"
    }
  }

}

# Auto Scaling Group ----------------------------------------------
resource "aws_autoscaling_group" "asg" {
  name                = "${local.tag_header}codedeploy-asg"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  vpc_zone_identifier = data.aws_subnets.target_subnets.ids

  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.tag_header}asg"
    propagate_at_launch = true
  }
}

# ################################################################################
# CodeDeploy Application & Deployment Group
# ================================================================================
resource "aws_codedeploy_app" "app" {
  name = "${local.tag_header}asg-codedeploy-app"
  # 배포 대상 정의: Server / Lambda / ECS
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "dg" {
  deployment_group_name = "${local.tag_header}asg-deployment-group"
  # codedeploy_app 리소스 이름
  app_name = aws_codedeploy_app.app.name

  service_role_arn = aws_iam_role.codedeploy_role.arn

  # 배포 대상 정의
  autoscaling_groups = [aws_autoscaling_group.asg.name]

  # 배포 전략 지정
  # "CodeDeployDefault.AllAtOnce": 타켓 인스턴스 전체에 동시에 한번에 배포하는 방식
  # "OneAtATime": 한 대씩 순차 배포(1대 배포 --> 검증 및 다음 배포 대상 선정 --> 순차 반복)
  # "HalfAtATime": 대상 인스턴스의 50%를 먼저 배포 후 나머지 배포
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
}

# ################################################################################
# 연결 리소스 생성 및 CodePipeline 리소스 생성
# ================================================================================
# AWS - GitHub 간 CodeStar Connection 생성
# 주의: 리소스 타입은 codestar"connections" (codestart 아님, 오타 수정)
# 생성 후 콘솔에서 GitHub 인증 승인 필요 (승인 전 상태: PENDING)
resource "aws_codestarconnections_connection" "github" {
  name          = "${local.tag_header}github-connection"
  provider_type = "GitHub" # 대문자 H 권장
}

# ################################################################################
# AWS CodePipeline 생성
# ================================================================================
# 수정 사항: stage 블록은 반드시 aws_codepipeline 리소스 "안"에 있어야 한다.
#           (기존에는 리소스가 먼저 닫혀서 stage 가 최상위에 놓여 오류 발생)
#           또한 stage 는 최소 2개 필요 (Source + Deploy)
resource "aws_codepipeline" "codepipeline" {
  name = "${local.tag_header}asg-cicd-pipeline"

  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket

    type = "S3"
  }

  # ##############################################################################
  # Stage 1: Source
  # ==============================================================================
  stage {
    name = "Source"
    action {
      name     = "Source"
      category = "Source"
      owner    = "AWS"                      # 액션 제공자(AWS에서 제공하는 서비스 활용)
      provider = "CodeStarSourceConnection" # GitHub V2액션과 연동 표준인 "CodeStarSourceConnection" 사용
      version  = "1"
      # zip 소스 압축파일을 다음 스테이지로 전달할 전달용 아티팩트 이름 선언
      output_artifacts = ["source_output"]
      # Github 연동을 위한 속성 값 정의
      configuration = {
        # 오타 수정: codestartconnections -> codestarconnections
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "Christian-Shim/ex9" # GitHub "owner/repo"
        BranchName       = "main"
      }
    }
  }

  # ##############################################################################
  # Stage 2: Deploy
  # ==============================================================================
  stage {
    name = "Deploy"
    action {
      name     = "Deploy"
      category = "Deploy"
      owner    = "AWS"        # 액션 제공자(AWS에서 제공하는 서비스 활용)
      provider = "CodeDeploy" # CodeDeploy 로 EC2(ASG)에 배포
      version  = "1"
      # Source 스테이지의 산출물(zip)을 입력으로 받음
      input_artifacts = ["source_output"]
      # CodeDeploy 배포 대상 지정 (GitHub 속성이 아니라 앱/배포그룹 이름 필요)
      configuration = {
        ApplicationName     = aws_codedeploy_app.app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.dg.deployment_group_name
      }
    }
  }
}
