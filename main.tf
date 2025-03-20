terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
    }
  }
}

provider "aws" {
  alias  = "mumbai"
  region = "ap-south-1"
}

provider "aws" {
  alias  = "us-east"
  region = "us-east-1"
}

# Mumbai Security Group
resource "aws_security_group" "mumbai_sg" {
  provider    = aws.mumbai
  name        = "mumbai-nginx-sg"
  description = "Allow HTTP traffic on port 80"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Mumbai Nginx SG"
  }
}

# US-East Security Group
resource "aws_security_group" "us_east_sg" {
  provider    = aws.us-east
  name        = "us-east-nginx-sg"
  description = "Allow HTTP traffic on port 80"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Open to all
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "US East Nginx SG"
  }
}

# Mumbai Instance
resource "aws_instance" "firstInstance" {
  provider      = aws.mumbai
  ami           = "ami-00bb6a80f01f03502"
  instance_type = var.instance_type
  #   vpc_security_group_ids = [aws_security_group.mumbai_sg.id]

 associate_public_ip_address = true 

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install nginx -y
                sudo systemctl start nginx 
                sudo systemctl enable nginx
                EOF

  tags = {
    Name = "Mumbai Server"
  }
}

# US-East Instance
resource "aws_instance" "secondInstance" {
  provider               = aws.us-east
  ami                    = "ami-0c7217cdde317cfec"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.us_east_sg.id]

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt install nginx -y
                sudo systemctl start nginx
                sudo systemctl enable nginx
                EOF

  tags = {
    Name = "US East Server"
  }
}



output "mumbai_instance_public_ip" {
  value       = aws_instance.firstInstance.public_ip
  description = "Public IP of Mumbai Server"
}

output "us_east_instance_public_ip" {
  value       = aws_instance.secondInstance.public_ip
  description = "Public IP of US East Server"
}
