#!/bin/bash
# This script lists all EC2 instances with their Name, Private IP, and Public IP.
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
# This command retrieves each instance's Name tag, PrivateIpAddress, and PublicIpAddress.
instances_json=$(aws ec2 describe-instances --query 'Reservations[*].Instances[*].{Name: Tags[?Key==`Name`].Value | [0], PrivateIp: PrivateIpAddress, PublicIp: PublicIpAddress}' --output json)

# Print header
printf "%-30s %-20s %-20s\n" "Instance Name" "Private IP" "Public IP"
printf "%-30s %-20s %-20s\n" "-------------" "----------" "---------"

# Parse JSON and output each instance's details.
echo "$instances_json" | jq -r '.[][] | "\(.Name // "N/A")\t\(.PrivateIp // "N/A")\t\(.PublicIp // "N/A")"' | while IFS=$'\t' read -r name private_ip public_ip; do
    printf "%-30s %-20s %-20s\n" "$name" "$private_ip" "$public_ip"
done
