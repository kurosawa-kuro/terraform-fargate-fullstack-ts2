##############################################################################
# Terraform ブロック & プロバイダ設定
##############################################################################
terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  type    = string
  default = "ap-northeast-1"
}

##############################################################################
# デフォルト VPC ＆ サブネットデータソースの取得
#  - デフォルト VPC 内の「デフォルトパブリックサブネット」を取得して使用します
##############################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  # デフォルトのパブリックサブネットは "default-for-az" = "true" となっている場合が多い
  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

##############################################################################
# セキュリティグループ
#  - ALB: ポート80を全公開
#  - Frontend: ALB → ポート3000
#  - Backend: Frontend → ポート8080
##############################################################################
resource "aws_security_group" "alb_sg" {
  name        = "fullstack-01-alb-sg"
  description = "Security group for ALB (HTTP 80 only)"
  vpc_id      = data.aws_vpc.default.id

  # ALB へのインバウンド: ポート80を全許可
  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALB からのアウトバウンドはすべて許可（循環参照回避）
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fullstack-01-alb-sg"
  }
}

resource "aws_security_group" "frontend_sg" {
  name        = "fullstack-01-frontend-sg"
  description = "Security group for Frontend ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  # Frontend へのインバウンド: ALB SG からポート3000を許可
  ingress {
    description     = "Allow HTTP from ALB to Frontend"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Frontend のアウトバウンドはすべて許可（循環参照回避）
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fullstack-01-frontend-sg"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "fullstack-01-backend-sg"
  description = "Security group for Backend ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  # Backend へのインバウンド: Frontend SG からポート8080を許可
  ingress {
    description     = "Allow Frontend to call Backend(8080)"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  # Backend のアウトバウンドはすべて許可
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fullstack-01-backend-sg"
  }
}

##############################################################################
# ALB & リスナー & ターゲットグループ
##############################################################################
resource "aws_lb" "alb" {
  name               = "fullstack-01-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.public.ids

  tags = {
    Name = "fullstack-01-alb"
  }
}

resource "aws_lb_target_group" "frontend_tg" {
  name     = "fullstack-01-frontend-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  target_type = "ip"

  # ルートパス "/" をヘルスチェックに使用
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 3
  }

  # 依存関係の正しい削除順序を保証するためのライフサイクル設定
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "fullstack-01-frontend-tg"
  }
}

resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }

  # リソース削除時の依存関係を適切に処理するためにライフサイクルを追加
  lifecycle {
    create_before_destroy = true
  }
}

##############################################################################
# ECS クラスター
##############################################################################
resource "aws_ecs_cluster" "cluster" {
  name = "fullstack-01-cluster"
  tags = {
    Name = "fullstack-01-cluster"
  }
}

##############################################################################
# IAM ロール (タスク実行用)
##############################################################################
data "aws_iam_policy_document" "ecs_task_execution_role_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "fullstack-01-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role_assume.json

  tags = {
    Name = "fullstack-01-ecs-task-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##############################################################################
# CloudWatch Logs グループ (Frontend / Backend)
##############################################################################
resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name              = "/ecs/fullstack-01-frontend"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "backend_log_group" {
  name              = "/ecs/fullstack-01-backend"
  retention_in_days = 30
}

##############################################################################
# タスク定義
#  - Frontend タスク (frontend-3000)
#  - Backend タスク (backend-8080)
##############################################################################
resource "aws_ecs_task_definition" "frontend_td" {
  family                   = "fullstack-01-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<EOT
[
  {
    "name": "frontend",
    "image": "kurosawakuro/frontend-3000",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.aws_region}",
        "awslogs-group": "${aws_cloudwatch_log_group.frontend_log_group.name}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOT

  tags = {
    Name = "fullstack-01-frontend-td"
  }
}

resource "aws_ecs_task_definition" "backend_td" {
  family                   = "fullstack-01-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<EOT
[
  {
    "name": "backend",
    "image": "kurosawakuro/backend-8080",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 8080,
        "hostPort": 8080
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.aws_region}",
        "awslogs-group": "${aws_cloudwatch_log_group.backend_log_group.name}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOT

  tags = {
    Name = "fullstack-01-backend-td"
  }
}

##############################################################################
# ECS サービス
#  - Frontend は ALB と連携
#  - Backend は内部呼び出し用 (LB不要)
##############################################################################
resource "aws_ecs_service" "frontend_service" {
  name            = "fullstack-01-frontend-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.frontend_td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.public.ids
    security_groups  = [aws_security_group.frontend_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = "frontend"
    container_port   = 3000
  }

  depends_on = [aws_lb_listener.alb_listener_http]

  # リソース削除時の依存関係を適切に処理するためにライフサイクルを追加
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "fullstack-01-frontend-service"
  }
}

resource "aws_ecs_service" "backend_service" {
  name            = "fullstack-01-backend-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.backend_td.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.public.ids
    security_groups  = [aws_security_group.backend_sg.id]
    assign_public_ip = true
  }

  # LB は不要: Frontend から直接 8080 で呼び出す想定
  depends_on = [aws_ecs_service.frontend_service]

  tags = {
    Name = "fullstack-01-backend-service"
  }
}
