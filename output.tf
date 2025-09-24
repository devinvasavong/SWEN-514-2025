output "instance_ip_addr" {
  # Shows private IPs as a list (because of [*])
  value = aws_instance.my_server[*].private_ip
}

output "public_ip"  {
  # Shows the single public IP (string)
  value = aws_instance.my_server.public_ip
}

output "public_dns" {
  # Shows the single public DNS name (string)
  value = aws_instance.my_server.public_dns
}