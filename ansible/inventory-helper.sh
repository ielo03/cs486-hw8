#!/bin/bash
# This script builds an Ansible inventory file dynamically based on the private IPs
# of EC2 instances with Name tags like Ubuntu-EC2- and AmazonLinux-EC2-.
# It requires AWS CLI and jq to be installed.

# Check for AWS CLI
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it and try again."
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install it and try again."
    exit 1
fi

# Query AWS for instance details.
# This command retrieves each instance's Name tag and PrivateIpAddress.
instances_json=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Name: Tags[?Key==`Name`].Value | [0], PrivateIp: PrivateIpAddress}' --output json)

# Define the output inventory file
inventory_file="inventory.ini"

# Start with fresh file and add Ubuntu group
echo "[ubuntu]" > "$inventory_file"
echo "$instances_json" | jq -r '.[][] | select(.Name | test("^Ubuntu-EC2-")) | "\(.Name) ansible_host=\(.PrivateIp) ansible_user=ubuntu"' | sort >> "$inventory_file"

# Add a blank line and then the Amazon Linux group
echo "" >> "$inventory_file"
echo "[amazonlinux]" >> "$inventory_file"
echo "$instances_json" | jq -r '.[][] | select(.Name | test("^AmazonLinux-EC2-")) | "\(.Name) ansible_host=\(.PrivateIp) ansible_user=ec2-user"' | sort >> "$inventory_file"

echo "Inventory file created: $inventory_file"