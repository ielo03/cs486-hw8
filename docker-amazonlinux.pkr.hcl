packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
s
variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "ssh_public_key_path" {
  type    = string
}

source "amazon-ebs" "amazon_linux" {
  region = var.aws_region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  instance_type = "t2.micro"
  ssh_username  = "ec2-user"
  ami_name      = "custom-amazon-linux-docker-{{timestamp}}"
}

build {
  sources = [
    "source.amazon-ebs.amazon_linux"
  ]

  # Update the system and install Docker
  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo chkconfig docker on"
    ]
  }

  # Upload your SSH public key to a temporary location
  provisioner "file" {
    source      = var.ssh_public_key_path
    destination = "/tmp/my_public_key"
  }

  # Append your SSH public key to the authorized_keys file
  provisioner "shell" {
    inline = [
      "mkdir -p /home/ec2-user/.ssh",
      "cat /tmp/my_public_key >> /home/ec2-user/.ssh/authorized_keys",
      "chown -R ec2-user:ec2-user /home/ec2-user/.ssh",
      "chmod 600 /home/ec2-user/.ssh/authorized_keys"
    ]
  }
}