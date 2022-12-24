#!/usr/bin/env bash

set -e

#include the whitespace to exclude non relevant results
DOMAINS=($(find /etc/nginx/sites/ -name "*.conf" -print0 | xargs -0 grep server_name | sed -n -e 's/^.*server_name //p' | sed -n -e 's/;$//p'))

if [ -z "$DOMAINS" ]; then
  echo "DOMAINS environment variable is not set"
  exit 1;
fi

sign_domain_cert() {
  local domain="$1"
  mkdir -p "/etc/nginx/site_certs/$domain"
  openssl genrsa -out "/etc/nginx/site_certs/$domain/privkey.pem" 2048
  printf "[dn]\nCN=${domain}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$domain\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" > "/etc/nginx/site_certs/$domain/openssl.cnf"
  openssl req \
  -x509 \
  -CA "/app/data/ca_certs/CA.pem" \
  -CAkey "/app/data/ca_certs/CA.key" \
  -CAcreateserial \
  -days 825 \
  -sha256 \
  -extfile "/etc/nginx/site_certs/$domain/openssl.cnf" \
  -out "/etc/nginx/site_certs/$domain/fullchain.pem" \
  -keyout "/etc/nginx/site_certs/$domain/privkey.pem" \
  -newkey rsa:2048 \
  -nodes \
  -sha256 \
  -subj "/CN=${domain}" \
  -extensions EXT \
  -config "/etc/nginx/site_certs/$domain/openssl.cnf"
}

fake_domain_cert() {
  local domain="$1"
  mkdir -p "/etc/nginx/site_certs/$domain"
  printf "[dn]\nCN=${domain}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$domain\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" > "/etc/nginx/site_certs/$domain/openssl.cnf"
  openssl req \
  -x509 \
  -out "/etc/nginx/site_certs/$domain/fullchain.pem" \
  -keyout "/etc/nginx/site_certs/$domain/privkey.pem" \
  -newkey rsa:2048 \
  -nodes \
  -sha256 \
  -subj "/CN=${domain}" \
  -extensions EXT \
  -config "/etc/nginx/site_certs/$domain/openssl.cnf"
}

# domains_fixed=$(echo "$DOMAINS" | tr -d \")
for domain in ${DOMAINS[@]}; do
  should_generate_cert=0
  echo "Checking configuration for $domain"
  # Determine whether cert renewal is needed
  if [ ! -f "/etc/nginx/site_certs/$domain/fullchain.pem" ]; then
    echo "No certificate exists - generating new dummy certificate for $domain"
    should_generate_cert=1
  elif ! openssl x509 -checkend 86400 -noout -in "/etc/nginx/site_certs/$domain/fullchain.pem"; then
    echo "Existing certificate is expired - generating new dummy certificate for $domain"
    should_generate_cert=1
  fi
  # Determine whether we can generate authenticate cert or must fake it
  if [ $should_generate_cert -eq 1 ]; then
    if [ -f "/app/data/ca_certs/CA.key" ] && [ -f "/app/data/ca_certs/CA.pem" ]; then
      echo "Signing cert with provided CA key"
      sign_domain_cert $domain
    else
      echo "Generating dummy cert"
      fake_domain_cert $domain
    fi
  fi
done