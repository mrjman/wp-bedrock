#!/bin/bash -xe

directory="/var/www/wordpress/coachella/web"
chown -R apache:apache "$directory"
find "$directory" -type d -exec chmod 750 {} \;
find "$directory" -type f -exec chmod 640 {} \;
