# NGINX Docker image

## Get started
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