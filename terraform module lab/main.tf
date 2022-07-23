provider "aws" {
    # location of your credential
    shared_credentials_files = ["/Users/daweizhang/.aws/config"]
    # name of your profile
    profile = "beamdata-dawei"
    region = "us-east-1"
}



# create a new vpc
resource "aws_vpc" "terraform-ec2-vpc" {
    cidr_block = var.cidr_blocks
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

module "subnet"{
    source = "./modules/subnet"
    vpc_id = aws_vpc.terraform-ec2-vpc.id
    subnet_cidr_block = var.subnet_cidr_block
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
}

# configure the security group
# open port 22 and 8080 as inbound rule for ssh and web app
# open port for all as outbound rule for the instance to have access to internet


module "webserver"{
    source = "./modules/webserver"
    vpc_id = aws_vpc.terraform-ec2-vpc.id
    my_ip = var.my_ip
    env_prefix = var.env_prefix
    image_name = var.image_name
    public_key_location = var.public_key_location
    avail_zone = var.avail_zone
    subnet_id = module.subnet.subnet.id
    instance_type = var.instance_type
}