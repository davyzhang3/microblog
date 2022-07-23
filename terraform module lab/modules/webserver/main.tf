resource "aws_security_group" "terraform-ec2-sg" {
    name = "terraform-ec2-sg"
    vpc_id = var.vpc_id

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
        # values = ["amzn2-ami-hvm-*-x86_64-gp2"]
        values = [var.image_name]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}


resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = "${file(var.public_key_location)}"
}
resource "aws_instance" "terraform-ec2-server"{
    ami = data.aws_ami.latest-amazon-linux-image.id
    # create the instance
    instance_type = var.instance_type
    subnet_id = var.subnet_id
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
    #                 d a security group that attached to the vpc which leaves the terraform destroy hanging
    tags = {
        Name: "${var.env_prefix}-server"
    }
}