terraform {
  required_version = ">=0.13.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.0.0" 
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# VPC for Core
resource "aws_vpc" "Core-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Core-vpc"
  }
}

# VPC for RAN
resource "aws_vpc" "RAN-vpc" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "RAN-vpc"
  }
}

# VPC for Monitoring
resource "aws_vpc" "Monitoring-vpc" {
  cidr_block           = "10.2.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Monitoring-vpc"
  }
}

#Public subnet for core
resource "aws_subnet" "core-subnet" {
  vpc_id                  = aws_vpc.Core-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "core-subsub"
  }
}

#Public subnet for RAN
resource "aws_subnet" "RAN-subnet" {
  vpc_id                  = aws_vpc.RAN-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "RAN-subnet"
  }
}

#Public subnet for Monitoring
resource "aws_subnet" "Monitoring-subnet" {
  vpc_id                  = aws_vpc.Monitoring-vpc.id
  cidr_block              = "10.2.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"
  tags = {
    Name = "Monitoring-subnet"
  }
}

#Core Internet Gateway 

resource "aws_internet_gateway" "Core-igw" {
  vpc_id = aws_vpc.Core-vpc.id

  tags = {
    Name = "Core-igw"
  }
}

#RAN Internet Gateway 

resource "aws_internet_gateway" "RAN-igw" {
  vpc_id = aws_vpc.RAN-vpc.id

  tags = {
    Name = "RAN-igw"
  }
}

#Monitoring Internet Gateway 

resource "aws_internet_gateway" "Monitoring-igw" {
  vpc_id = aws_vpc.Monitoring-vpc.id

  tags = {
    Name = "Monitoring-igw"
  }
}

# Route table for Core-igw

resource "aws_route_table" "core_igw_rt" {
  vpc_id = aws_vpc.Core-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Core-igw.id
  }

  tags = {
    Name = "Core_igw_rt"
  }
}

# Route table for RAN-igw

resource "aws_route_table" "RAN_igw_rt" {
  vpc_id = aws_vpc.RAN-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.RAN-igw.id
  }

  tags = {
    Name = "RAN_igw_rt"
  }
}

# Route table for Monitoring-igw

resource "aws_route_table" "Monitoring_igw_rt" {
  vpc_id = aws_vpc.Monitoring-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Monitoring-igw.id
  }

  tags = {
    Name = "Monitoring_igw_rt"
  }
}

# Subnet association for Core
resource "aws_route_table_association" "Core-sa" {
  subnet_id      = aws_subnet.core-subnet.id
  route_table_id = aws_route_table.core_igw_rt.id
}

# Subnet association for RAN
resource "aws_route_table_association" "RAN-sa" {
  subnet_id      = aws_subnet.RAN-subnet.id
  route_table_id = aws_route_table.RAN_igw_rt.id
}

# Subnet association for Monitoring
resource "aws_route_table_association" "Monitoring-sa" {
  subnet_id      = aws_subnet.Monitoring-subnet.id
  route_table_id = aws_route_table.Monitoring_igw_rt.id
}

# Public security group
resource "aws_security_group" "Core_sg" {
  name        = "public-sg"
  description = "Allow ssh and all traffic"
  vpc_id      = aws_vpc.Core-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Core_sg"
  }
}

# Public security group RAN
resource "aws_security_group" "RAN_sg" {
  name        = "RAN-sg"
  description = "Allow ssh and all traffic"
  vpc_id      = aws_vpc.RAN-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RAN_sg"
  }
}

# Public security group Monitoring
resource "aws_security_group" "Monitoring_sg" {
  name        = "Monitoring-sg"
  description = "Allow ssh and all traffic"
  vpc_id      = aws_vpc.Monitoring-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Monitoring_sg"
  }
}



resource "aws_key_pair" "open5gs_kp" {
  key_name   = "open5gs_kp"
  public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "open5gs_kp" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "open5gs_kp"
}


# EC2 instance for core
resource "aws_instance" "core-ec2" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t3.medium"
# vpc_id                      = aws_vpc.Core-vpc.id
  key_name                    = "open5gs_kp"
  vpc_security_group_ids      = [aws_security_group.Core_sg.id]
  subnet_id                   = aws_subnet.core-subnet.id
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    host        = aws_instance.core-ec2.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.rsa.private_key_pem
  }

  provisioner "file" {
    source      = "./open5gs_kp"
    destination = "/home/ubuntu/open5gs_kp"
  }

    root_block_device {
      volume_size = 25
      volume_type = "io1"
      iops        = 100
    }
  tags = {
    Name = "core-ec2"
  }
}

# Null resource for public EC2
resource "null_resource" "Core-null-res" {
  connection {
    type        = "ssh"
    host        = aws_instance.core-ec2.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.rsa.private_key_pem
  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      file("${path.module}/microk8s.sh"),
      "#!/bin/bash",
      "kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.22/deploy/local-path-storage.yaml",
      "kubectl patch storageclass local-path -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"true\"}}}'",
      file("${path.module}/core.sh")
    ]
  }
  depends_on = [aws_instance.core-ec2]
}

# EC2 instance for RAN
resource "aws_instance" "RAN-ec2" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.medium"
  # vpc_id                      = aws_vpc.Core-vpc.id
  key_name                    = "open5gs_kp"
  vpc_security_group_ids      = [aws_security_group.RAN_sg.id]
  subnet_id                   = aws_subnet.RAN-subnet.id
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    host        = aws_instance.RAN-ec2.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.rsa.private_key_pem
  }

  provisioner "file" {
    source      = "./open5gs_kp"
    destination = "/home/ubuntu/open5gs_kp"
  }

    root_block_device {
      volume_size = 25
      volume_type = "io1"
      iops        = 100
    }
  tags = {
    Name = "RAN-ec2"
  }
}

# Null resource for public EC2
resource "null_resource" "RAN-null-res" {
  connection {
    type        = "ssh"
    host        = aws_instance.RAN-ec2.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.rsa.private_key_pem
  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      file("${path.module}/microk8s.sh"),
      file("${path.module}/ran.sh")
    ]
  }
  depends_on = [aws_instance.RAN-ec2]
}


# EC2 instance for Monitoring
resource "aws_instance" "performance" {
  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.medium"
  # vpc_id                      = aws_vpc.Core-vpc.id
  key_name                    = "open5gs_kp"
  vpc_security_group_ids      = [aws_security_group.Monitoring_sg.id]
  subnet_id                   = aws_subnet.Monitoring-subnet.id
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    host        = aws_instance.Monitoring-ec2.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.rsa.private_key_pem
  }

  provisioner "file" {
    source      = "./open5gs_kp"
    destination = "/home/ubuntu/open5gs_kp"
  }

  #   root_block_device {
  #     volume_size = 25
  #     volume_type = "io1"
  #     iops        = 100
  #   }
  tags = {
    Name = "performance"
  }
}

# Null resource for public EC23456789edited
resource "null_resource" "Monitoring-null-res" {
  connection {
    type        = "ssh"
    host        = aws_instance.performance.public_ip
    user        = "ubuntu"
    private_key = tls_private_key.rsa.private_key_pem
  }
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      file("${path.module}/microk8s.sh"),
      file("${path.module}/Monitoring.sh")
    ]
  }
  depends_on = [aws_instance.performance]
}