//to print out public ip
output "docker_ip" {
  value = aws_instance.docker.public_ip
}

output "maven_ip" {
  value = aws_instance.maven.public_ip
}