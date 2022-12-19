#!/usr/bin/env bash
if [ ! -f /etc/nginx/global_certs/ssl-dhparams.pem ]; then
  mkdir -p "/etc/nginx/global_certs"
  openssl dhparam -out /etc/nginx/global_certs/ssl-dhparams.pem 2048
fi