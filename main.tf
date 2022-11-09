terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
  required_version = ">= 1.1.9"
}

provider "aws" {
  region = var.region
}

resource "aws_security_group" "ns" {
  name = "${var.name}_ns"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nightscout" {
  ami                         = var.ami
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.ns.id]
  associate_public_ip_address = true
  user_data                   = file("init.sh")

  tags = {
    Name = "${var.name}-ec2"
  }
}

output "nightscout-ip" {
  value = aws_instance.nightscout.public_ip
}
