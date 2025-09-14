

resource "aws_launch_template" "web" {
  name_prefix            = "${var.project}-lt"
  image_id               = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = base64encode(<<EOT
#!/bin/bash
apt-get update -y
apt-get install -y nginx
echo "healthy" > /var/www/html/healthy
echo "Hello from $(hostname)" > /var/www/html/index.html
systemctl enable nginx
systemctl start nginx
EOT
  )
}
