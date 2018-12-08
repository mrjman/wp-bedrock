#!/bin/bash -xe
export WP_CLI_PACKAGES_DIR="/var/cache/wp-cli"
site_directory="/var/www/wordpress/coachella"

cd "$site_directory"
cp ".env.example" ".env"

# get acf pro key from ssm and remove quotes from the end of the string
acf_pro_key=$(aws ssm get-parameters --region us-east-1 --names coa.wp.acf_pro_key --with-decryption --query Parameters[0].Value)
acf_pro_key=`echo $acf_pro_key | sed -e 's/^"//' -e 's/"$//'`

wp dotenv set ACF_PRO_KEY $acf_pro_key --quote-double --allow-root

COMPOSER_HOME="/var/cache/composer" composer install
