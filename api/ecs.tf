# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"
}

# IAM Policy Document for ECS Task Roles
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# IAM Role for Task Execution (used by ECS for pulling images and sending logs)
resource "aws_iam_role" "execution" {
  name               = "${var.prefix}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy" "ecs_task_execution_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.execution.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_role.arn
}

# IAM Role for Task (used by your container for AWS API calls)
resource "aws_iam_role" "task" {
  name               = "${var.prefix}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# Attach DynamoDB Full Access policy to task role
resource "aws_iam_role_policy_attachment" "dynamodb_access" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Attach S3 Full Access policy to task role
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# CloudWatch Log Group for ECS logs
resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.prefix}"
  retention_in_days = 1
}

# ECS Task Definition with both execution_role_arn and task_role_arn
resource "aws_ecs_task_definition" "main" {
  family             = "${var.prefix}-task"
  task_role_arn      = aws_iam_role.task.arn    # Role assumed by the container for AWS API calls
  execution_role_arn = aws_iam_role.execution.arn

  container_definitions = <<EOF
[
  {
    "name": "${var.prefix}-container",
    "image": "${aws_ecr_repository.main.repository_url}:latest",
    "portMappings": [
      {
        "containerPort": 3000,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/${var.prefix}",
        "awslogs-region": "${var.aws_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOF

  cpu                      = "256"
  memory                   = "512"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  tags = {
    Project = var.prefix
  }
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.prefix}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  launch_type     = "FARGATE"

  desired_count = 1

  network_configuration {
    assign_public_ip = true
    subnets          = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id
    ]
    security_groups  = [aws_security_group.ecs_tasks.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "${var.prefix}-container"
    container_port   = 3000
  }

  tags = {
    Project = var.prefix
  }
}
