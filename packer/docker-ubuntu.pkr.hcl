packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "ssh_public_key_path" {
  type    = string
}

source "amazon-ebs" "ubuntu" {
  region = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }
  instance_type = "t2.micro"
  ssh_username  = "ubuntu"
  ami_name      = "custom-ubuntu-docker-{{timestamp}}"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  # Update the system and install Docker
  provisioner "shell" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",
      "sudo systemctl enable docker"
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
      "mkdir -p /home/ubuntu/.ssh",
      "cat /tmp/my_public_key >> /home/ubuntu/.ssh/authorized_keys",
      "chown -R ubuntu:ubuntu /home/ubuntu/.ssh",
      "chmod 600 /home/ubuntu/.ssh/authorized_keys"
    ]
  }
}