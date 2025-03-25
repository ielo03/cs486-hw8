# cs486-hw8

## How to deploy the IaC

### 1

Ensure aws credentials are properly set up

Install the aws cli if not already installed

Run the command `aws sts get-caller-identity` to check if your
credentials are configured.

If they are not configured run the command `aws configure` to
configure them, and follow all the steps.

### 2

Set up a key pair in aws and extract the public key

Run the following commands within the cs486-hw8 directory or
wherever you would like to save the keys. If you change the
directory you will need to ensure that the paths are correct in the
packer and terraform variable files. Change the name of the key and
files if you like.

```
aws ec2 create-key-pair --key-name my-new-key --query 'KeyMaterial' --output text > my-new-key.pem
chmod 400 my-new-key.pem
ssh-keygen -y -f my-new-key.pem > my-new-key.pub
```

### 3

Update packer variables

- Edit the vars.pkrvars.hcl file
- Update the aws region
- Update the absolute path to your public key file

### 4

Run packer init

- Within the cs486-hw8 directory run the command `packer init -var-file=vars.pkrvars.hcl docker-amazonlinux.pkr.hcl`

### 5

Run packer build

- Within the cs486-hw8 directory run the command `packer build -var-file=vars.pkrvars.hcl docker-amazonlinux.pkr.hcl`
- Record the ami

Successful output:

```
==> Wait completed after 3 minutes 27 seconds

==> Builds finished. The artifacts of successful builds are:
--> amazon-ebs.amazon_linux: AMIs were created:
us-west-1: ami-0your_ami_number
```

### 6

Update terraform variables

- Edit the infra/terraform.tfvars file
- Replace my_ip with your ip (run `curl -4 ifconfig.me` or go to
  [whatismyipaddress.com](https://whatismyipaddress.com/)). ensure
  you have the /32 after your ipv4 ip
- Replace key_pair_name with your key pair name if you changed it
  during step 2
- Replace bastion_ami with an ami of your choice or use the base
  Amazon Linux 2023 ami
- Replace custom_ami with the ami output by packer build
- Update any default values to your liking

### 7
