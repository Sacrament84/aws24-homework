# provider and region
provider "aws" {
        region = var.aws_region
}
#main vpc
resource "aws_vpc" "terra_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "TerraVPC"
  }
}
# internet gateway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "main"
  }
}
# subnet private1
resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.terra_vpc.id
  cidr_block              = var.subnets_cidr1
  availability_zone       = var.azs1 
  map_public_ip_on_launch = true
  tags = {
    Name = "Private-Subnet-1"
  }
}
#  subnet private2
resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.terra_vpc.id
  cidr_block              = var.subnets_cidr2
  availability_zone       = var.azs2
  map_public_ip_on_launch = true
  tags = {
    Name = "Private-Subnet-2"
  }
}
# subnet group for RDS
resource "aws_db_subnet_group" "rds" {
  name       = "rds"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}
# main route table
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
}
# route to internet gateway
resource "aws_route" "route_igw" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.main_rt.id
  gateway_id             = aws_internet_gateway.terra_igw.id
  depends_on             = [aws_internet_gateway.terra_igw]
}
# route table association to az1
resource "aws_route_table_association" "az1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.main_rt.id
}
# route table association to az1
resource "aws_route_table_association" "az2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.main_rt.id
}
