# VPC
resource "aws_vpc" "mlops_handson" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.prefix}-mlops-handson"
  }
}

# SecurityGroup for ML Pipeline
resource "aws_security_group" "ml_pipeline" {
  name        = "${var.prefix}-mlops-handson-ml-pipeline-sg"
  description = "security group for mlops handson ml pipeline"
  vpc_id      = aws_vpc.mlops_handson.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-mlops-handson-ml-pipeline-sg"
  }
}

# SecurityGroup for application load balancer
resource "aws_security_group" "alb" {
  name        = "${var.prefix}-mlops-handson-alb-sg"
  description = "security group for mlops handson alb"
  vpc_id      = aws_vpc.mlops_handson.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-mlops-handson-alb-sg"
  }
}


# SecurityGroup for predict api
resource "aws_security_group" "predict_api" {
  name        = "${var.prefix}-mlops-handson-predict-api-sg"
  description = "security group for mlops handson predict api"
  vpc_id      = aws_vpc.mlops_handson.id
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb.id}"]
  }
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.prefix}-mlops-handson-predict-api-sg"
  }
}


# Public Subnet (ap-northeast-1a)
resource "aws_subnet" "public1a" {
  vpc_id            = aws_vpc.mlops_handson.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "${var.prefix}-mlops-handson-public-subnet-1a"
  }
}

# Public Subnet (ap-northeast-1c)
resource "aws_subnet" "public1c" {
  vpc_id            = aws_vpc.mlops_handson.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "${var.prefix}-mlops-handson-public-subnet-1c"
  }
}


# Private Subnets (ap-northeast-1a)
resource "aws_subnet" "private1a" {
  vpc_id            = aws_vpc.mlops_handson.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.10.0/24"

  tags = {
    Name = "${var.prefix}-mlops-handson-private-subnet-1a"
  }
}

# Private Subnets (ap-northeast-1c)
resource "aws_subnet" "private1c" {
  vpc_id            = aws_vpc.mlops_handson.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.20.0/24"

  tags = {
    Name = "${var.prefix}-mlops-handson-private-subnet-1c"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "mlops_handson" {
  vpc_id = aws_vpc.mlops_handson.id

  tags = {
    Name = "${var.prefix}-mlops-handson-igw"
  }
}


# Route Table (Public)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mlops_handson.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mlops_handson.id
  }

  tags = {
    Name = "${var.prefix}-mlops-handson-public-route"
  }
}

# Association (Public ap-northeast-1a)
resource "aws_route_table_association" "public1a" {
  subnet_id      = aws_subnet.public1a.id
  route_table_id = aws_route_table.public.id
}

# Association (Public ap-northeast-1c)
resource "aws_route_table_association" "public1c" {
  subnet_id      = aws_subnet.public1c.id
  route_table_id = aws_route_table.public.id
}


# Route Table (Private)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.mlops_handson.id

  tags = {
    Name = "${var.prefix}-mlops-handson-private-route"
  }
}

# Association (Private ap-northeast-1a)
resource "aws_route_table_association" "private1a" {
  subnet_id      = aws_subnet.private1a.id
  route_table_id = aws_route_table.private.id
}

# Association (Private ap-northeast-1c)
resource "aws_route_table_association" "private1c" {
  subnet_id      = aws_subnet.private1c.id
  route_table_id = aws_route_table.private.id
}

## VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.mlops_handson.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = ["${aws_route_table.private.id}"]
  tags = {
    Name = "${var.prefix}-mlops-handson-s3-vpe"
  }
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id              = aws_vpc.mlops_handson.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = ["${aws_subnet.private1a.id}", "${aws_subnet.private1c.id}"]
  security_group_ids  = ["${aws_security_group.ml_pipeline.id}", "${aws_security_group.predict_api.id}"]
  tags = {
    Name = "${var.prefix}-mlops-handson-ecr-dkr-vpe"
  }
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id              = aws_vpc.mlops_handson.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = ["${aws_subnet.private1a.id}", "${aws_subnet.private1c.id}"]
  security_group_ids  = ["${aws_security_group.ml_pipeline.id}", "${aws_security_group.predict_api.id}"]
  tags = {
    Name = "${var.prefix}-mlops-handson-ecr-api-vpe"
  }
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.mlops_handson.id
  service_name        = "com.amazonaws.ap-northeast-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = ["${aws_subnet.private1a.id}", "${aws_subnet.private1c.id}"]
  security_group_ids  = ["${aws_security_group.ml_pipeline.id}", "${aws_security_group.predict_api.id}"]
  tags = {
    Name = "${var.prefix}-mlops-handson-secretsmanager-vpe"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.mlops_handson.id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = ["${aws_subnet.private1a.id}", "${aws_subnet.private1c.id}"]
  security_group_ids  = ["${aws_security_group.ml_pipeline.id}", "${aws_security_group.predict_api.id}"]
  tags = {
    Name = "${var.prefix}-mlops-handson-ssm-vpe"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.mlops_handson.id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = ["${aws_subnet.private1a.id}", "${aws_subnet.private1c.id}"]
  security_group_ids  = ["${aws_security_group.ml_pipeline.id}", "${aws_security_group.predict_api.id}"]
  tags = {
    Name = "${var.prefix}-mlops-handson-logs-vpe"
  }
}
