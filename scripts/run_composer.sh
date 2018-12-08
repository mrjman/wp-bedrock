#!/bin/bash -xe
export WP_CLI_PACKAGES_DIR="/var/cache/wp-cli"
site_directory="/var/www/wordpress/coachella"

cd "$site_directory"
cp ".env.example" ".env"

# get keys from ssm and remove quotes from the end of the string
acf_pro_key=$(aws ssm get-parameters --region us-east-1 --names coa.wp.acf_pro_key --with-decryption --query Parameters[0].Value)
acf_pro_key=`echo $acf_pro_key | sed -e 's/^"//' -e 's/"$//'`

db_name=$(aws ssm get-parameters --region us-east-1 --names coa.wp.dev.db.name --with-decryption --query Parameters[0].Value)
db_name=`echo $db_name | sed -e 's/^"//' -e 's/"$//'`

db_user=$(aws ssm get-parameters --region us-east-1 --names coa.wp.dev.db.username --with-decryption --query Parameters[0].Value)
db_user=`echo $db_user | sed -e 's/^"//' -e 's/"$//'`

db_password=$(aws ssm get-parameters --region us-east-1 --names coa.wp.dev.db.password --with-decryption --query Parameters[0].Value)
db_password=`echo $db_password | sed -e 's/^"//' -e 's/"$//'`

db_host=$(aws ssm get-parameters --region us-east-1 --names coa.wp.dev.db.host --with-decryption --query Parameters[0].Value)
db_host=`echo $db_host | sed -e 's/^"//' -e 's/"$//'`

wp dotenv set DB_NAME $db_name --allow-root
wp dotenv set DB_USER $db_user --allow-root
wp dotenv set DB_PASSWORD $db_password --allow-root
wp dotenv set DB_HOST $db_host --allow-root
wp dotenv set "ACF_PRO_KEY" "$acf_pro_key" --quote-double --allow-root

COMPOSER_HOME="/var/cache/composer" composer install
