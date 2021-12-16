terraform {
    // reference: https://www.terraform.io/language/settings/backends/s3
    backend "s3" {
        bucket = "weclouddata-devops-lab"
        key = "microblog/state.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
    # location of your credential
    shared_credentials_file = "/Users/daweizhang/.aws/config"
    # name of your profile
    profile = "beamdata-dawei"
    region = "us-east-1"
}

variable cidr_blocks {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip{}
variable instance_type{}
variable public_key_location{}

# create a new vpc
resource "aws_vpc" "terraform-ec2-vpc" {
    cidr_block = var.cidr_blocks
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

# create a new subnet
resource "aws_subnet" "terraform-ec2-subnet-1" {
    vpc_id = aws_vpc.terraform-ec2-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

# create a new route table
resource "aws_route_table" "terraform-ec2-route-table" {
    vpc_id = aws_vpc.terraform-ec2-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.terraform-ec2-igw.id
    }

    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}

# create a internet gateway for the VPC
resource "aws_internet_gateway" "terraform-ec2-igw" {
    vpc_id = aws_vpc.terraform-ec2-vpc.id
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}

# associate the aws route table with the subnet that just got created
resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.terraform-ec2-subnet-1.id
    route_table_id = aws_route_table.terraform-ec2-route-table.id
}

# configure the security group
# open port 22 and 8080 as inbound rule for ssh and web app
# open port for all as outbound rule for the instance to have access to internet
resource "aws_security_group" "terraform-ec2-sg" {
    name = "terraform-ec2-sg"
    vpc_id = aws_vpc.terraform-ec2-vpc.id

    ingress {
        from_port = 22
        to_port = 22 # a range, from 22 to 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip] # list of IP address allowed to access the server
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
        Name: "${var.env_prefix}-sg"
    }
}

# get the image you expected
data "aws_ami" "latest-amazon-linux-image"{
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}
# output the image id
output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = "${file(var.public_key_location)}"
}
resource "aws_instance" "terraform-ec2-server"{
    ami = data.aws_ami.latest-amazon-linux-image.id
    # create the instance
    instance_type = var.instance_type
    subnet_id = aws_subnet.terraform-ec2-subnet-1.id
    vpc_security_group_ids = [aws_security_group.terraform-ec2-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true # asscociate public ip to the server so that we could ssh to it

    #key_name = "demo tutorial" # use pem file to ssh to the server
    key_name = aws_key_pair.ssh-key.key_name # now you don't have to ssh with a pem file

    # run nginx docker container in the ec2-user
    user_data = file("entry-script.sh")
    # user_data = <<EOF
    #                 #!/bin/bash
    #                 sudo yum update -y && sudo yum install -y docker # -y means yes
    #                 sudo systemctl start docker
    #                 sudo usermod -aG docker ec2-user # add ec2-user to docker group
    #                 docker run -p 8080:80 nginx
    #             EOF

    tags = {
        Name: "${var.env_prefix}-server"
    }
}

output "ec2_public_ip" {
    value = aws_instance.terraform-ec2-server.public_ip
}