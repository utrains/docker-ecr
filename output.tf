output "ssh-command" {
  value = "ssh -i ${aws_key_pair.ec2_key.key_name}.pem ec2-user@${aws_instance.DockerInstance.public_dns}"
}

output "public-ip" {
  value = aws_instance.DockerInstance.public_ip
}
output "ecr_url" {
  value = aws_ecr_repository.ecr1.repository_url
}
