resource "aws_launch_template" "springboot" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = "ami-xxxxxxxx"
  instance_type = "t3.medium"


  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2_sg.id]
  }
}

resource "aws_autoscaling_group" "springboot_asg" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 2
  vpc_zone_identifier  = aws_subnet.private.*.id
  launch_template {
    id      = aws_launch_template.springboot.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg.arn]
}
