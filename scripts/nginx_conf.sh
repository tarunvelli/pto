#!/bin/bash

# Enable nginx + Passenger
rm -f /etc/service/nginx/down

# cleanup default site config
rm /etc/nginx/sites-enabled/default

cat > /etc/nginx/nginx.conf <<EOF
  # Nginx config for Ruby App
  worker_processes 2;
  pid /run/nginx.pid;
  daemon off;

  # Logging to STDOUT
  error_log /dev/stdout info;

  events {
    worker_connections 1024;
  }

  http {
    sendfile on;
    keepalive_timeout 65;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
    passenger_ruby /usr/bin/ruby;
    passenger_friendly_error_pages off;

    client_max_body_size 5m;

    server {
      listen 8080;
      server_name ${MS_NAME}_webapp;
      root /pipeline/source/public;

      passenger_app_root /pipeline/source;
      passenger_enabled on;
      passenger_app_env ${RAILS_ENV};

      error_page 404 /404.html;
      error_page 500 502 503 504 /500.html;

      location /healthcheck {
        return 200;
      }

      location /ping {
        return 200;
      }
    }

    # Logging to STDOUT
    access_log /dev/stdout;
  }
EOF
