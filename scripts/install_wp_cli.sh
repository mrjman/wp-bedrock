#!/bin/bash -xe
if ! [ -x "$(command -v wp)" ]; then
  curl -o "/bin/wp" "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
  chmod +x "/bin/wp"
fi

wp_cli_packages_path="/var/cache/wp-cli"
if [ ! -d "$wp_cli_packages_path" ]; then
  mkdir -p "$wp_cli_packages_path"
  # chown apache:apache "$wp_cli_packages_path"
fi

export WP_CLI_PACKAGES_DIR="$wp_cli_packages_path"

if ! wp package path "aaemnnosttv/wp-cli-dotenv-command" --allow-root; then
  wp package install "aaemnnosttv/wp-cli-dotenv-command:^1.0" --allow-root
fi
