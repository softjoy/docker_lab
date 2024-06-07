
#creating local name for my resources
locals {
  name = "row"
}

# RSA key of size 4096 bits
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

//creating private key
resource "local_file" "key" {
  content         = tls_private_key.key.private_key_pem
  filename        = "rowjenkey"
  file_permission = 400
}

//creating public key
resource "aws_key_pair" "key" {
  key_name   = "rowjenkey"
  public_key = tls_private_key.key.public_key_openssh
}

//creating seccurity group
resource "aws_security_group" "docker-sg" {
  name        = "docker instance"
  description = "docker instance secuirty group"

  ingress {
    description = "ssh port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  ingress {
    description = "application port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  ingress {
    description = "nginx port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }

  tags = {
    Name = "${local.name}-docker-sg"
  }
}

//creating seccurity group
resource "aws_security_group" "maven-sg" {
  name        = "maven sg"
  description = "prod instance secuirty group"

  ingress {
    description = "ssh port"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  ingress {
    description = "application port"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.allcidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allcidr]
  }

  tags = {
    Name = "${local.name}-maven-sg"
  }
}

//creating docker instance
resource "aws_instance" "docker" {
  ami                         = var.redhat //docker redhat ami
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.docker-sg.id]
  associate_public_ip_address = true
  user_data                   = file("./userdata1.sh")
  tags = {
    Name = "${local.name}-docker"
  }
}

//creating maven insstance
resource "aws_instance" "maven" {
  ami                         = var.redhat //maven redhat ami
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.key.id
  vpc_security_group_ids      = [aws_security_group.maven-sg.id]
  associate_public_ip_address = true
  user_data                   = file("./userdata2.sh")
  tags = {
    Name = "${local.name}-maven"
  }
}




