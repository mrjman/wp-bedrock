#!/bin/bash -xe

tmp_directory="/tmp/coachella"
site_directory="/var/www/wordpress/coachella"

if [ -d "$site_directory" ]; then
  rm -rf "$site_directory"
fi

mv "$tmp_directory" "$site_directory"
chown -R apache:apache "$site_directory"
find "$site_directory" -type d -exec chmod 750 {} \;
find "$site_directory" -type f -exec chmod 640 {} \;

httpd_conf_file="/etc/httpd/conf.d/coachella.conf"
rm -rf "$httpd_conf_file"
echo "ServerSignature Off" >> "$httpd_conf_file"
echo "ServerTokens Prod" >> "$httpd_conf_file"
echo "ServerName 127.0.0.1:80" >> "$httpd_conf_file"
echo "DocumentRoot $site_directory/web" >> "$httpd_conf_file"
echo "<Directory $site_directory/web>" >> "$httpd_conf_file"
echo "  Options Indexes FollowSymLinks" >> "$httpd_conf_file"
echo "  AllowOverride All" >> "$httpd_conf_file"
echo "  Require all granted" >> "$httpd_conf_file"
echo "</Directory>" >> "$httpd_conf_file"
