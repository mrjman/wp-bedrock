#!/bin/bash -xe
export COMPOSER_HOME="/var/cache/composer"
export WP_CLI_PACKAGES_DIR="/var/cache/wp-cli"
site_directory="/tmp/coachella"

cd "$site_directory"

if [ ! -f ".env" ]; then
  touch ".env"
fi

# cp ".env.example" ".env"

env_namespace=$DEPLOYMENT_GROUP_NAME

if [ $env_namespace == "production" ]; then
  wp_environment="production"
  frontend_url="http://coa.prod.mondorobot.com"
elif [ $env_namespace == "staging" ]; then
  wp_environment="staging"
  frontend_url="http://coa.stg.mondorobot.com"
else
  wp_environment="development"
  frontend_url="http://coa.dev.mondorobot.com"
fi

db_name=$(aws ssm get-parameters --region us-east-1 --names "/coa/wp/$env_namespace/db/name" --with-decryption --query Parameters[0].Value --output text)
db_user=$(aws ssm get-parameters --region us-east-1 --names "/coa/wp/$env_namespace/db/username" --with-decryption --query Parameters[0].Value --output text)
db_password=$(aws ssm get-parameters --region us-east-1 --names "/coa/wp/$env_namespace/db/password" --with-decryption --query Parameters[0].Value --output text)
db_host=$(aws ssm get-parameters --region us-east-1 --names "/coa/wp/$env_namespace/db/host" --with-decryption --query Parameters[0].Value --output text)
url=$(aws ssm get-parameters --region us-east-1 --names "/coa/wp/$env_namespace/url" --with-decryption --query Parameters[0].Value --output text)
acf_pro_key=$(aws ssm get-parameters --region us-east-1 --names "/coa/wp/$env_namespace/acf_pro_key" --with-decryption --query Parameters[0].Value --output text)
uploads_access_key_id=$(aws ssm get-parameters --region us-east-1 --names "/coa/wp/$env_namespace/uploads/access_key_id" --with-decryption --query Parameters[0].Value --output text)
uploads_access_key_secret=$(aws ssm get-parameters --region us-east-1 --names "/coa/wp/$env_namespace/uploads/access_key_secret" --with-decryption --query Parameters[0].Value --output text)
uploads_bucket=$(aws ssm get-parameters --region us-east-1 --names "/coa/wp/$env_namespace/uploads/bucket" --with-decryption --query Parameters[0].Value --output text)
uploads_cdn_url=$(aws ssm get-parameters --region us-east-1 --names "/coa/wp/$env_namespace/uploads/cdn_url" --with-decryption --query Parameters[0].Value --output text)

# set env variables
wp dotenv set "WP_ENV" "$wp_environment" --quote-double
wp dotenv set "DB_NAME" "$db_name" --quote-double
wp dotenv set "DB_USER" "$db_user" --quote-double
wp dotenv set "DB_PASSWORD" "$db_password" --quote-double
wp dotenv set "DB_HOST" "$db_host" --quote-double
wp dotenv set "WP_HOME" "$url" --quote-double
wp dotenv set "WP_SITEURL" "${WP_HOME}/wp" --quote-double
wp dotenv set "ACF_PRO_KEY" "$acf_pro_key" --quote-double
wp dotenv set "ILAB_CLOUD_STORAGE_PROVIDER" "s3" --quote-double
wp dotenv set "ILAB_AWS_S3_ACCESS_KEY" "$uploads_access_key_id" --quote-double
wp dotenv set "ILAB_AWS_S3_ACCESS_SECRET" "$uploads_access_key_secret" --quote-double
wp dotenv set "ILAB_AWS_S3_BUCKET" "$uploads_bucket" --quote-double
wp dotenv set "ILAB_AWS_S3_REGION" "us-east-1" --quote-double
wp dotenv set "ILAB_MEDIA_S3_PREFIX" "uploads" --quote-double
wp dotenv set "ILAB_AWS_S3_CACHE_CONTROL" "public,max-age=2592000" --quote-double
wp dotenv set "FRONTEND_URL" "$frontend_url" --quote-double
wp dotenv salts generate

# run composer
composer install

# activate theme
wp theme activate coachella-headless

# set permalink structure
wp rewrite structure "/%postname%/" --hard

# set additional options
wp option update blog_public "0"
wp option update uploads_use_yearmonth_folders "0"
wp option update default_comment_status "closed"
wp option update default_ping_status "closed"
wp option update default_pingback_flag "0"
wp option update ilab-media-tool-enabled-storage "1"
wp option update ilab-media-s3-delete-uploads "on"
wp option update ilab-media-s3-display-s3-badge "on"

if [ -n "$uploads_cdn_url" ]; then
  wp option update ilab-media-s3-cdn-base "$uploads_cdn_url"
fi

# find "$site_directory" -type d -exec chmod 750 {} \;
# find "$site_directory" -type f -exec chmod 640 {} \;
