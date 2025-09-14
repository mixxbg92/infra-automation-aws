#!/usr/bin/env bash
set -euxo pipefail

# Basic updates + Nginx install (Amazon Linux 2023)
DNF=dnf
$DNF -y update
$DNF -y install nginx

# Fetch metadata for instance info using IMDSv2
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Write homepage
cat >/usr/share/nginx/html/index.html <<EOF
<!doctype html>
<html>
  <head><title>${project_name} - It works!</title></head>
  <body style="font-family:sans-serif;">
    <h1>${project_name}: Nginx is up :) /h1>
    <p><b>Instance:</b> $INSTANCE_ID</p>
    <p><b>AZ:</b> $AZ</p>
  </body>
</html>
EOF

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx

# Ensure Nginx auto-restarts if it crashes
mkdir -p /etc/systemd/system/nginx.service.d
cat >/etc/systemd/system/nginx.service.d/override.conf <<'EOT'
[Service]
Restart=always
RestartSec=3
EOT
systemctl daemon-reload
systemctl restart nginx