output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "public_ip" {
  description = "Public IP address"
  value       = var.enable_static_ip ? aws_eip.main[0].public_ip : aws_instance.main.public_ip
}

output "ssh_command" {
  description = "SSH connection command"
  value       = "ssh -i <your-key.pem> ubuntu@${var.enable_static_ip ? aws_eip.main[0].public_ip : aws_instance.main.public_ip}"
}

output "application_url" {
  description = "AgentBridge workflow editor URL"
  value       = "http://${var.enable_static_ip ? aws_eip.main[0].public_ip : aws_instance.main.public_ip}:5678"
}

output "health_url" {
  description = "Health check endpoint"
  value       = "http://${var.enable_static_ip ? aws_eip.main[0].public_ip : aws_instance.main.public_ip}/health"
}

output "console_url" {
  description = "AWS EC2 Console link"
  value       = "https://${var.region}.console.aws.amazon.com/ec2/home?region=${var.region}#InstanceDetails:instanceId=${aws_instance.main.id}"
}

# --- Bedrock AI Orchestration Outputs ---
output "bedrock_flow_id" {
  description = "Bedrock Flow ID"
  value       = var.enable_bedrock ? aws_bedrockagent_flow.main[0].id : ""
}

output "bedrock_flow_arn" {
  description = "Bedrock Flow ARN"
  value       = var.enable_bedrock ? aws_bedrockagent_flow.main[0].arn : ""
}

output "bedrock_flow_alias_id" {
  description = "Bedrock Flow Alias ID"
  value       = var.enable_bedrock ? aws_bedrockagent_flow_alias.live[0].id : ""
}

output "bedrock_console_url" {
  description = "Bedrock Flows console link"
  value       = var.enable_bedrock ? "https://${var.region}.console.aws.amazon.com/bedrock/home?region=${var.region}#/flows/${aws_bedrockagent_flow.main[0].id}" : ""
}

