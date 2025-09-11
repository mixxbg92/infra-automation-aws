#!/bin/bash
set -eux

dnf -y update || true
dnf -y install nginx

cat >/usr/share/nginx/html/index.html <<'HTML'
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>WebStack Demo</title></head>
  <body style="font-family: system-ui, sans-serif; max-width: 720px; margin: 40px auto;">
    <h1>✅ It works!</h1>
    <p>Served from an EC2 behind an ALB in eu-central-1.</p>
    <p>Instance ID: <span id="iid"></span> | AZ: <span id="az"></span></p>
    <script>
      fetch('http://169.254.169.254/latest/meta-data/instance-id').then(r=>r.text()).then(t=>iid.textContent=t);
      fetch('http://169.254.169.254/latest/meta-data/placement/availability-zone').then(r=>r.text()).then(t=>az.textContent=t);
    </script>
  </body>
</html>
HTML

systemctl enable nginx
cat >/etc/systemd/system/nginx.service.d/override.conf <<'CONF'
[Service]
Restart=always
RestartSec=3
CONF
systemctl daemon-reload
systemctl restart nginx