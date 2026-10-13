terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


variable "my_ip" {
  type        = string
  description = "My Office Ip"
}


resource "aws_security_group" "main_sg"{
     
 name        = "main_sg"
 description = "Allow SSH from my ip and http from anywhere"

 tags = {
  Name =  "main_sg"
}
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.main_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "ssh"{
   security_group_id  = aws_security_group.main_sg.id
   cidr_ipv4          = var.my_ip
   from_port          = 22
   ip_protocol        = "tcp" 
   to_port            = 22  
}

resource "aws_vpc_security_group_egress_rule" "allow_outbound"{
    security_group_id = aws_security_group.main_sg.id
    cidr_ipv4         = "0.0.0.0/0"
    ip_protocol       = -1
}

resource "aws_instance" "prac_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.main_sg.id]
  user_data              = <<-EOF
                           #!/bin/bash
                            apt update -y     
                            apt install -y nginx
                            systemctl start nginx 
                            systemctl enable nginx
                            systemctl restart nginx
                           
                             echo "<h1>Hello Cloud</h1>" > /var/www/html/index.html
EOF


tags = {
   Name= "prac_instance"
}
}


output "server_ip" {
    value = aws_instance.prac_instance.public_ip
}
