output "instance_publicip" {
  description = "Public IP addresses of EC2 instances"
  value       = { for instance_key, instance_value in aws_instance.ec2-servers : instance_key => instance_value.public_ip }
}
