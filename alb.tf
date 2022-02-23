#alb
resource "aws_lb" "terra-elb" {
  name               = "terra-elb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.private1.id, aws_subnet.private2.id]
  security_groups    = [aws_security_group.elb.id]
  enable_deletion_protection = false
}
#alb listener
resource "aws_lb_listener" "wordpress" {
  load_balancer_arn = aws_lb.terra-elb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.wordpress_ec2.arn
  }
}
# alb target group
resource "aws_lb_target_group" "wordpress_ec2" {
  name     = "tg-wordpress"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.terra_vpc.id
}
#tg attachment 1
resource "aws_lb_target_group_attachment" "tg_attach_wp1" {
  target_group_arn = aws_lb_target_group.wordpress_ec2.arn
  target_id        = aws_instance.webserver1.id
  port             = 80
}
#tg attachment 2
resource "aws_lb_target_group_attachment" "tg_attach_wp2" {
  target_group_arn = aws_lb_target_group.wordpress_ec2.arn
  target_id        = aws_instance.webserver2.id
  port             = 80
}
# output elb dns name
output "Balancer-dns-name" {
  value = aws_lb.terra-elb.dns_name
}
