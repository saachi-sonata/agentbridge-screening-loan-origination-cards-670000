variable "aws_access_key" {
  description = "AWS access key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "image" {
  description = "AMI ID (Ubuntu 24.04 LTS)"
  type        = string
  default     = "ami-0c7217cdde317cfec"
}

variable "disk_size_gb" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 50
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 access"
  type        = string
  default     = ""
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "enable_static_ip" {
  description = "Assign an Elastic IP"
  type        = bool
  default     = false
}

variable "additional_storage_gb" {
  description = "Additional EBS volume size in GB (0 to skip)"
  type        = number
  default     = 0
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

# --- Bedrock AI Orchestration ---
variable "enable_bedrock" {
  description = "Enable AWS Bedrock Agents + Flow for AI orchestration"
  type        = bool
  default     = false
}

variable "bedrock_model_id" {
  description = "Foundation model ID for Bedrock Agents"
  type        = string
  default     = "us.amazon.nova-lite-v1:0"
}
