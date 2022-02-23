variable "aws_region" {
	default = "eu-west-2"
}

variable "vpc_cidr" {
	default = "10.0.0.0/16"
}

variable "subnets_cidr1" {
	default = "10.0.1.0/24"
}
variable "subnets_cidr2" {
        default = "10.0.2.0/24"
}

variable "azs1" {
	default = "eu-west-2a"
}
variable "azs2" {
        default = "eu-west-2b"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "database_name" {
  default = "wordpress"
}
variable "database_password" {}

variable "database_user" {
  default = "wordpress_user"
}

variable "instance_class" {
  default = "db.t2.micro"
}


