#!/bin/bash -xe
if ! [ -x "$(command -v composer)" ]; then
  curl -sS "https://getcomposer.org/installer" | php

  mv "composer.phar" "/usr/local/bin/composer"
  ln -s "/usr/local/bin/composer" "/usr/bin/composer"
fi

composer_home="/var/cache/composer"
if [ ! -d "$composer_home" ]; then
  mkdir -p "$composer_home"
  chown -R ec2-user:ec2-user "$composer_home"
fi
