variable "aws_region" {
  description = "AWS region to deploy in"
  type        = string
  default     = "us-west-1"
}

variable "my_ip" {
  description = "Your public IP address in CIDR format (e.g., 1.2.3.4/32)"
  type        = string
}

variable "key_pair_name" {
  description = "The name of an existing AWS key pair for SSH access"
  type        = string
}

variable "bastion_ami" {
  description = "AMI ID for the bastion host (Amazon Linux 2 is recommended)"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for the bastion host"
  type        = string
  default     = "t2.micro"
}

variable "custom_ami" {
  description = "Custom AMI ID created by Packer for the private instances"
  type        = string
}

variable "private_instance_type" {
  description = "Instance type for the private instances"
  type        = string
  default     = "t3.micro"
}