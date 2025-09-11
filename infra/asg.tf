data "aws_ami" "al2023" {
  owners      = ["amazon"]
  most_recent = true
  filter { name="name" values=["al2023-ami-*-x86_64"] }
}

resource "aws_launch_template" "web" {
  name_prefix   = "${var.project}-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  # No key_name (no SSH)
  user_data     = base64encode(file("${path.module}/user_data.sh"))
  vpc_security_group_ids = [aws_security_group.web.id]
  tag_specifications {
    resource_type = "instance"
    tags = { Name = "${var.project}-web" }
  }
}

resource "aws_autoscaling_group" "web" {
  name                      = "${var.project}-asg"
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 4
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]
  tag { key="Name" value="${var.project}-web" propagate_at_launch=true }
}