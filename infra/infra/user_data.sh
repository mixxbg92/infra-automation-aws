#!/bin/bash
set -euxo pipefail

# Update and install nginx
dnf -y update || true
dnf -y install nginx curl

# Enable and start nginx immediately
systemctl enable nginx
systemctl start nginx

# Wait until nginx is up (retry 10 times)
for i in {1..10}; do
  if curl -s http://localhost >/dev/null; then
    echo "Nginx is up!"
    break
  else
    echo "Waiting for nginx..."
    sleep 5
  fi
done

# Use IMDSv2 to get metadata inside the EC2 instance
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 60")

INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Write HTML page including the metadata values
cat >/usr/share/nginx/html/index.html <<HTML
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>WebStack Demo</title></head>
  <body style="font-family: system-ui, sans-serif; max-width: 720px; margin: 40px auto;">
    <h1>✅ It works!</h1>
    <p>Served from an EC2 behind an ALB in eu-central-1.</p>
    <p>Instance ID: ${INSTANCE_ID} | AZ: ${AZ}</p>
  </body>
</html>
HTML

# Restart nginx to load the new page
systemctl r
