#!/bin/bash
yum update -y
yum install -y httpd mysql

systemctl start httpd
systemctl enable httpd

cat > /var/www/html/index.html << EOF
<h1>Web Server</h1>
<p>Database Endpoint: ${db_endpoint}</p>
<p>Server: $(hostname)</p>
EOF
