#!/bin/bash

APP_DIR=/pipeline/source/
bash $APP_DIR/scripts/app_env_vars.sh
sed -i -e "s@test@$RAILS_ENV@" $APP_DIR/config/database.yml
bash $APP_DIR/scripts/nginx_conf.sh

service nginx start
