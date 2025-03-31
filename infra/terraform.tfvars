# Replace these values with your actual configuration.
my_ip = "138.202.171.252/32"
key_pair_name = "my-new-key"
bastion_ami = "ami-01eb4eefd88522422"       # Replace with a valid bastion host AMI ID, or keep the base Amazon Linux 2023 AMI ID
custom_ami = "ami-0e447e55b0c8fee50"     # Replace with the AMI ID output from your Packer build

# Default values
aws_region = "us-west-1"
bastion_instance_type = "t2.micro"
private_instance_type = "t3.micro"
