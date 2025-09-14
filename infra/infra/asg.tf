resource "aws_autoscaling_group" "web" {
  name                      = "${var.project}-asg"
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 2
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]

  tag {
    key                 = "Name"
    value               = "${var.project}-web"
    propagate_at_launch = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }
}
