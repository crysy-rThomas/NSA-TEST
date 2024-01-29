data "aws_region" "current" {
  name = "eu-west-3"
}
data "aws_key_pair" "ec2_key" {
  key_name = "goodenough"
  include_public_key = true
#  key_pair_id = "key-068121e8dbf6d4562"
}
### Create network side and VPC which will contain our VM
# create VPC
resource "aws_vpc" "vpc_nsa" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"
}

# create subnet
resource "aws_subnet" "subnet_nsa" {
  vpc_id = aws_vpc.vpc_nsa.id
  cidr_block = var.vpc_cidr
}

# create internet gateway
resource "aws_internet_gateway" "ig_nsa" {
  vpc_id = aws_vpc.vpc_nsa.id
}

# create route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc_nsa.id
  route {
    cidr_block = var.cidr_route
    gateway_id = aws_internet_gateway.ig_nsa.id
  }
}
resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.subnet_nsa.id
  route_table_id = aws_route_table.public_rt.id
}

# define security group
resource "aws_security_group" "sg_nsa" {
  name        = "sg_nsa"
  description = "Allow incoming traffic to the Linux EC2 Instance"
  vpc_id      = aws_vpc.vpc_nsa.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.cidr_route]
    description = "Allow incoming HTTP connections"
  }
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.cidr_route]
      description = "Allow incoming SSH connections"
    }
  egress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.cidr_route]
    description = "allow outgoing SSH connections"
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.cidr_route]
    description = "allow outgoing HTTP connections"
  }
}

#####create vms

resource "aws_instance" "db" {
  ami = data.aws_ami.debian-11.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.subnet_nsa.id
  associate_public_ip_address = true
  key_name = data.aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_nsa.id]
  depends_on = [
    aws_security_group.sg_nsa
  ]
  tags = {
    Name = "db"
  }
}
resource "aws_instance" "backend" {
  ami = data.aws_ami.debian-11.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.subnet_nsa.id
  associate_public_ip_address = true
  key_name = data.aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_nsa.id]
  depends_on = [
    aws_security_group.sg_nsa
  ]
  tags = {
    Name = "back"
  }
}
resource "aws_instance" "front" {
  ami = data.aws_ami.debian-11.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.subnet_nsa.id
  associate_public_ip_address = true
  key_name = data.aws_key_pair.ec2_key.key_name
  vpc_security_group_ids = [aws_security_group.sg_nsa.id]
  depends_on = [
    aws_security_group.sg_nsa
  ]
  tags = {
    Name = "front"
  }
}