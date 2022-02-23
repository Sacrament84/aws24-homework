#efs for wordpress
resource "aws_efs_file_system" "wp_efs" {
  encrypted = false
  tags = {
    Name = "WP_EFS"
  }
}
#mount target to subnet1
resource "aws_efs_mount_target" "private1" {
  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = aws_subnet.private1.id
  security_groups = [aws_security_group.sg_efs.id]
}
#mount target to subnet2
resource "aws_efs_mount_target" "private2" {
  file_system_id  = aws_efs_file_system.wp_efs.id
  subnet_id       = aws_subnet.private2.id
  security_groups = [aws_security_group.sg_efs.id]
}
