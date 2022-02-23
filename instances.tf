# define ami
data "aws_ami" "linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
# instance-1
resource "aws_instance" "webserver1" {
 ami = data.aws_ami.linux2.id
 instance_type   = var.instance_type
 security_groups = [aws_security_group.webservers.id]
 subnet_id       = aws_subnet.private1.id
 user_data       = data.template_file.user_data_wordpress.rendered
 depends_on      = [aws_db_instance.wordpressdb, aws_lb.terra-elb]
 tags = {
  Name = "Server-wordpress1"
  }
}
# instance-2
resource "aws_instance" "webserver2" {
 ami             = data.aws_ami.linux2.id
 instance_type   = var.instance_type
 security_groups = [aws_security_group.webservers.id]
 subnet_id       = aws_subnet.private2.id
 user_data       = data.template_file.user_data_wordpress.rendered
 depends_on      = [aws_db_instance.wordpressdb, aws_lb.terra-elb]
 tags = {
  Name = "Server-wordpress2"
  }
}
# rds instance
resource "aws_db_instance" "wordpressdb" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = var.instance_class
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_name                   = var.database_name
  username               = var.database_user
  password               = var.database_password
  multi_az               = true
  skip_final_snapshot    = true
}
# change variables in user data after creating rds
data "template_file" "user_data_wordpress" {
 template           = file ("./user_data_wordpress.tpl")
 vars = {
    db_username      = var.database_user
    db_user_password = var.database_password
    db_name          = var.database_name
    db_rds           = aws_db_instance.wordpressdb.endpoint
    efs              = aws_efs_file_system.wp_efs.id
    url              = aws_lb.terra-elb.dns_name
 }
}
