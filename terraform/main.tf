terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    blueprint = "Screening • Loan Origination (Cards)"
    environment = "production"
    Name = "agentbridge-screening---loan-origination--cards-"
    Environment = "production"
    ManagedBy = "terraform"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "agentbridge-screening---loan-origination--cards--igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "agentbridge-screening---loan-origination--cards--public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "agentbridge-screening---loan-origination--cards--rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group
resource "aws_security_group" "main" {
  name_prefix = "agentbridge-screening---loan-origination--cards--"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Application"
    from_port   = 5678
    to_port     = 5678
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "API"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "agentbridge-screening---loan-origination--cards--sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Key Pair
resource "aws_key_pair" "deploy" {
  count      = var.ssh_public_key != "" ? 1 : 0
  key_name   = "agentbridge-screening---loan-origination--cards-"
  public_key = var.ssh_public_key
}

# EC2 Instance
resource "aws_instance" "main" {
  ami                    = var.image
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.main.id]
  key_name               = var.ssh_public_key != "" ? aws_key_pair.deploy[0].key_name : null

  user_data = file("${path.module}/scripts/cloud-init.yml")

  root_block_device {
    volume_size = var.disk_size_gb
    volume_type = "gp3"
    encrypted   = true
  }

  monitoring = var.enable_monitoring

  tags = {
    blueprint = "Screening • Loan Origination (Cards)"
    environment = "production"
    Name = "agentbridge-screening---loan-origination--cards-"
    Environment = "production"
    ManagedBy = "terraform"
  }
}

# Elastic IP
resource "aws_eip" "main" {
  count    = var.enable_static_ip ? 1 : 0
  instance = aws_instance.main.id
  domain   = "vpc"
  tags = {
    Name = "agentbridge-screening---loan-origination--cards--eip"
  }
}

# Additional EBS Volume
resource "aws_ebs_volume" "data" {
  count             = var.additional_storage_gb > 0 ? 1 : 0
  availability_zone = aws_instance.main.availability_zone
  size              = var.additional_storage_gb
  type              = "gp3"
  encrypted         = true
  tags = {
    Name = "agentbridge-screening---loan-origination--cards--data"
  }
}

resource "aws_volume_attachment" "data" {
  count       = var.additional_storage_gb > 0 ? 1 : 0
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.data[0].id
  instance_id = aws_instance.main.id
}

# ═══════════════════════════════════════════════════════════════════
# AWS Bedrock Agents + Flow (AI Orchestration)
# Creates one Bedrock Agent per workflow step, chains them in a Flow
# ═══════════════════════════════════════════════════════════════════

# IAM Role for Bedrock Flow execution
resource "aws_iam_role" "bedrock_flow" {
  count = var.enable_bedrock ? 1 : 0
  name  = "agentbridge-screening---loan-origination--cards--bedrock-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = { Service = "bedrock.amazonaws.com" }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name      = "agentbridge-screening---loan-origination--cards--bedrock-role"
    ManagedBy = "terraform"
  }
}

resource "aws_iam_role_policy" "bedrock_invoke" {
  count = var.enable_bedrock ? 1 : 0
  name  = "bedrock-invoke-policy"
  role  = aws_iam_role.bedrock_flow[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "arn:aws:bedrock:${var.region}::foundation-model/*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeAgent",
          "bedrock:InvokeFlow"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Instance Profile for EC2 to invoke Bedrock
resource "aws_iam_role" "ec2_bedrock" {
  count = var.enable_bedrock ? 1 : 0
  name  = "agentbridge-screening---loan-origination--cards--ec2-bedrock"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ec2_bedrock_invoke" {
  count = var.enable_bedrock ? 1 : 0
  name  = "ec2-bedrock-invoke"
  role  = aws_iam_role.ec2_bedrock[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeFlow",
          "bedrock:InvokeAgent",
          "bedrock:InvokeModel"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "aws-marketplace:MeterUsage",
          "aws-marketplace:RegisterUsage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_bedrock" {
  count = var.enable_bedrock ? 1 : 0
  name  = "agentbridge-screening---loan-origination--cards--ec2-profile"
  role  = aws_iam_role.ec2_bedrock[0].name
}

# Bedrock Agent per workflow step


# Bedrock Flow — chains all agents: Input → Agent1 → Agent2 → ... → Output
resource "aws_bedrockagent_flow" "main" {
  count              = var.enable_bedrock ? 1 : 0
  name               = "agentbridge-screening---loan-origination--cards--flow"
  execution_role_arn = aws_iam_role.bedrock_flow[0].arn

  tags = {
    Blueprint = "Screening • Loan Origination (Cards)"
    ManagedBy = "terraform"
  }
}

resource "aws_bedrockagent_flow_alias" "live" {
  count  = var.enable_bedrock ? 1 : 0
  name   = "live"
  flow_id = aws_bedrockagent_flow.main[0].id

  routing_configuration {
    flow_version = "$LATEST"
  }
}
