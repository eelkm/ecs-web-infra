resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Project = var.prefix
    Name    = "${var.prefix}-vpc"
  }
}

# First public subnet in AZ-a
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Project = var.prefix
    Name    = "${var.prefix}-public-subnet-a"
  }
}

# Second public subnet in AZ-b
resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Project = var.prefix
    Name    = "${var.prefix}-public-subnet-b"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Project = var.prefix
    Name    = "${var.prefix}-igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Project = var.prefix
    Name    = "${var.prefix}-public-route-table"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnet_association_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_route_table.id
}


# Security group for ALB
resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb"
  description = "Allow inbound HTTP/HTTPS traffic to the ALB"
  vpc_id      = aws_vpc.main.id

  # Allow public traffic to the ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow public HTTP traffic
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow public HTTPS traffic
  }

  # Allow outbound traffic from the ALB
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.prefix
  }
}


# Security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.prefix}-ecs-tasks"
  description = "Allow ALB-to-ECS traffic"
  vpc_id      = aws_vpc.main.id

  # Allow ALB to communicate with ECS tasks
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # Allow traffic from ALB security group
  }

  # Allow outbound traffic from ECS tasks
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project = var.prefix
  }
}

