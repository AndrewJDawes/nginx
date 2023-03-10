#!/usr/bin/env bash

set -e

#include the whitespace to exclude non relevant results
DOMAINS=($(find /etc/nginx/sites/ -name "*.conf" -print0 | xargs -0 grep server_name | sed -n -e 's/^.*server_name //p' | sed -n -e 's/;$//p' | sort | uniq))

if [ -z "$DOMAINS" ]; then
  echo "DOMAINS environment variable is not set"
  exit 1
fi

generate_domain_csr() {
  local domain="$1"
  # Generate a key for the domain
  openssl genrsa -out "/etc/nginx/site_certs/$domain/privkey.pem" 2048

  openssl req \
    -new \
    -key "/etc/nginx/site_certs/$domain/privkey.pem" \
    -out "/etc/nginx/site_certs/$domain/child.csr" \
    -subj "/CN=${domain}"

  cat >"/etc/nginx/site_certs/$domain/openssl.cnf" <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $domain
EOF

}


request_domain_cert() {
  local domain="$1"

  # Generate a key and CSR for the domain
  generate_domain_csr $domain

  # Request signed certificate and output it to fullchain.pem
  curl -k -L -X POST -F domain="$domain" -F csr=@"/etc/nginx/site_certs/$domain/child.csr" "$CSR_REQUEST_ENDPOINT" -o "/etc/nginx/site_certs/$domain/fullchain.pem"
}


sign_domain_cert() {
  local domain="$1"

  # Generate a key and CSR for the domain
  generate_domain_csr $domain

  openssl x509 \
    -req \
    -in "/etc/nginx/site_certs/$domain/child.csr" \
    -CA "/app/data/ca_certs/CA.pem" \
    -CAkey "/app/data/ca_certs/CA.key" \
    -CAcreateserial \
    -out "/etc/nginx/site_certs/$domain/fullchain.pem" \
    -days 825 \
    -sha256 \
    -extfile "/etc/nginx/site_certs/$domain/openssl.cnf"
}

fake_domain_cert() {
  local domain="$1"
  # Populate CSR config file
  printf "[dn]\nCN=${domain}\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:$domain\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth" >"/etc/nginx/site_certs/$domain/openssl.cnf"
  # Generate a self signed certificate
  openssl req \
    -x509 \
    -sha256 \
    -nodes \
    -newkey rsa:2048 \
    -keyout "/etc/nginx/site_certs/$domain/privkey.pem" \
    -out "/etc/nginx/site_certs/$domain/fullchain.pem" \
    -config "/etc/nginx/site_certs/$domain/openssl.cnf" \
    -subj "/CN=${domain}" \
    -extensions EXT
}

# domains_fixed=$(echo "$DOMAINS" | tr -d \")
for domain in ${DOMAINS[@]}; do
  mkdir -p "/etc/nginx/site_certs/$domain"
  should_generate_cert=0
  echo "$domain"
  echo "Checking configuration for $domain"
  # Determine whether cert renewal is needed
  if [ ! -f "/etc/nginx/site_certs/$domain/fullchain.pem" ]; then
    echo "No certificate exists - generating new certificate for $domain"
    should_generate_cert=1
  elif ! openssl x509 -checkend 86400 -noout -in "/etc/nginx/site_certs/$domain/fullchain.pem"; then
    echo "Existing certificate is expired - generating new certificate for $domain"
    should_generate_cert=1
  fi
  # Determine whether we can generate authenticate cert or must fake it
  if [ $should_generate_cert -eq 1 ]; then
    if [ -n "$CSR_REQUEST_ENDPOINT" ] && curl -k -L "$CSR_REQUEST_ENDPOINT"; then
      echo "Requesting CSR from endpoint: $CSR_REQUEST_ENDPOINT"
      request_domain_cert $domain
    elif [ -f "/app/data/ca_certs/CA.key" ] && [ -f "/app/data/ca_certs/CA.pem" ]; then
      echo "Signing cert with provided CA key"
      sign_domain_cert $domain
    else
      echo "Generating dummy cert"
      fake_domain_cert $domain
    fi
  fi
done
