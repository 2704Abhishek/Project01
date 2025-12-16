output "instance_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.web_server[0].public_ip
}
output "instance_public_Id" {
  description = "Public ID of EC2 instance"
  value       = aws_instance.web_server[0].id
}