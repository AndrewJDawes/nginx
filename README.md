# NGINX Docker image

## Get started

### Install a CA key and root certificate

[Article with examples](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/#becoming-certificate-authority)
`cd data/ca_certs`
`openssl genrsa -out CA.key 2048`
`openssl req -x509 -new -nodes -key CA.key -sha256 -days 1825 -out CA.pem`

### NGINX Config
- Copy `data/etc/nginx/conf.d/default.conf.example` to `data/etc/nginx/conf.d/default.conf`
- Copy `data/etc/nginx/sites/site.conf.example` to `data/etc/nginx/sites/<YOUR_HOST>.conf` where `<YOUR_HOST>` is your domain name - like `hello-world.com.conf`.
- Edit the copied .conf file to replace `${DOMAIN}` with your domain


## Start the image
`/bin/bash start.sh`

## Add more domains
- Copy `data/etc/nginx/sites/site.conf.example` to `data/etc/nginx/sites/<YOUR_HOST>.conf` where `<YOUR_HOST>` is your domain name - like `hello-world.com.conf`.
- Edit the copied .conf file to replace `${DOMAIN}` with your domain

## Hot reload NGINX
`docker exec nginx nginx -s reload`