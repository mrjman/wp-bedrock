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
