# create a new subnet
resource "aws_subnet" "terraform-ec2-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

# create a new route table
resource "aws_route_table" "terraform-ec2-route-table" {
    vpc_id = var.vpc_id

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
    vpc_id = var.vpc_id
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}

# associate the aws route table with the subnet that just got created
resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.terraform-ec2-subnet-1.id
    route_table_id = aws_route_table.terraform-ec2-route-table.id
}