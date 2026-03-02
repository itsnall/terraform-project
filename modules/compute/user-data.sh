#!/bin/bash

yum update -y
yum install -y httpd php php-mysqlnd
systemctl start httpd
systemctl enable httpd


cat << 'CONFIG' > /var/www/html/config.php
<?php
$db_endpoint = "${db_endpoint}";
$host = explode(":", $db_endpoint)[0];
$user = "admin";
$pass = "Admin123";
$db   = "fgd3database";
?>
CONFIG


cat << 'WEB' > /var/www/html/index.php
${index_php_content}
WEB


rm -f /var/www/html/index.html
systemctl restart httpd