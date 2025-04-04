terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Retrieve available AZs for the region.
data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  # Use the first two available AZs using the slice function.
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

# Security Group for the bastion host: allow SSH only from your IP.
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from my IP"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Bastion Host in the public subnet.
resource "aws_instance" "bastion" {
  ami                    = var.bastion_ami
  instance_type          = var.bastion_instance_type
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = var.key_pair_name
  associate_public_ip_address = true

  tags = {
    Name = "Bastion-Host"
  }
}

# Security Group for private instances.
resource "aws_security_group" "private_sg" {
  name        = "private-sg"
  description = "Security group for private EC2 instances"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "Allow SSH from Bastion Host"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 6 EC2 Instances in the private subnet using your custom AMI.
resource "aws_instance" "private_instances" {
  count                  = 6
  ami                    = var.custom_ami
  instance_type          = var.private_instance_type
  subnet_id              = element(module.vpc.private_subnets, count.index % length(module.vpc.private_subnets))
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "Private-EC2-${count.index + 1}"
  }
}