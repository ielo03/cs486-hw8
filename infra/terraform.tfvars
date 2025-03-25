# Replace these values with your actual configuration.
my_ip = "YOUR_PUBLIC_IP/32"
key_pair_name = "my-new-key"
bastion_ami = "ami-01eb4eefd88522422"       # Replace with a valid bastion host AMI ID (e.g., Amazon Linux 2)
custom_ami = "ami-0yourpackeramiid12345"     # Replace with the AMI ID output from your Packer build

# Default values
aws_region = "us-west-1"
bastion_instance_type = "t2.micro"
private_instance_type = "t3.micro"
