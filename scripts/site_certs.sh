#!/usr/bin/env bash

set -e

#include the whitespace to exclude non relevant results
DOMAINS=($(find /etc/nginx/sites/ -name "*.conf" -print0 | xargs -0 grep server_name | sed -n -e 's/^.*server_name //p' | sed -n -e 's/;$//p'))

if [ -z "$DOMAINS" ]; then
  echo "DOMAINS environment variable is not set"
  exit 1;
fi

# domains_fixed=$(echo "$DOMAINS" | tr -d \")
for domain in ${DOMAINS[@]}; do
  echo "Checking configuration for $domain"

  if [ ! -f "/etc/nginx/site_certs/$domain/fullchain.pem" ]; then
    echo "Generating dummy certificate for $domain"
    mkdir -p "/etc/nginx/site_certs/$domain"
    printf "[dn]\nCN=${domain}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$domain\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" > openssl.cnf
    openssl req -x509 -out "/etc/nginx/site_certs/$domain/fullchain.pem" -keyout "/etc/nginx/site_certs/$domain/privkey.pem" \
      -newkey rsa:2048 -nodes -sha256 \
      -subj "/CN=${domain}" -extensions EXT -config openssl.cnf
    rm -f openssl.cnf
  fi

done