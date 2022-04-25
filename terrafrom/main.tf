# provider and backend

provider "aws" {
  region = "us-east-1"
}

backend "s3" {
  bucket = "example-bucket"
  key = "test/terraform.tfstate"
  region = "us-east-1"
}

# network configuration

resource "aws_vpc" "example-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_subnet" "example-subnet" {
  vpc_id            = aws_vpc.example-vpc.id
  cidr_block        = "10.1.0.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "tf-example"
  }
}

resource "aws_network_interface" "interface" {
  subnet_id   = aws_subnet.example-subnet.id
  security_groups = [aws_security_group.ec2.id]
}

# EC2 configuration

resource "aws_instance" "example-server" {
  ami           = "ami-005e54dee72cc1d00" 
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.test_profile.name
  key_name               = "key"
  network_interface {
    network_interface_id = aws_network_interface.interface.id
    device_index         = 0
  }
  }

resource "aws_key_pair" "example-key" {
  key_name   = "key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

resource "aws_security_group" "ec2" {
  vpc_id = aws_vpc.example-vpc.id
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["107.22.40.20/32", "18.215.226.36/32"]
  }

  ingress {
    description = "Https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "ip" {
  vpc      = true
  instance = aws_instance.example-server.id
}

# RDS configuration

resource "aws_secretsmanager_secret" "database_password" {
  name = "/dev/database/password/master"
}

resource "aws_db_instance" "example-DB" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  username             = "user"
  password             = aws_secretsmanager_secret.database_password.arn
  parameter_group_name = "default.mysql5.7"
}
