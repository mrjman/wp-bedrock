#!/bin/bash -xe
if ! [ -x "$(command -v composer)" ]; then
  curl -sS "https://getcomposer.org/installer" | php

  mv "composer.phar" "/usr/local/bin/composer"
  ln -s "/usr/local/bin/composer" "/usr/bin/composer"
fi

if ! [ -x "$(command -v composer)" ]; then
  curl -o "/bin/wp" "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
  chmod +x "/bin/wp"
  wp package install "aaemnnosttv/wp-cli-dotenv-command:^1.0" --allow-root
fi

composer_home="/var/cache/composer"
if [ ! -d "$composer_home" ]; then
  mkdir -p "$composer_home"
  chown apache:apache "$composer_home"
fi
