# NGINX Docker image

## Get started

### OPTION 1 - Use a CSR signing endpoint

-   Make sure the endpoint meets these requirements:
    -   Accepts HTTP POST requests
    -   Expects POST request to contain form data inputs for `domain` (string) and `csr` (which is a CSR file)
    -   Returns a signed certificate file
-   If your endpoint does not meet these requirements, you can't use it without modifying scripts in this repo and generating new docker images
-   If your endpoint **does** meet these requirements, set it as an environment variable
    -   `CSR_REQUEST_ENDPOINT=<your_endpoint_here>`

### OPTION 2 - Install a self-signed CA key and root certificate

-   Articles
    -   [Article with examples](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/#becoming-certificate-authority)
    -   [freeCodeCamp cheat sheet](https://www.freecodecamp.org/news/openssl-command-cheatsheet-b441be1e8c4a/)
-   Change to mounted volume
    -   `cd data/ca_certs`
-   Generate a CA key
    -   `openssl genrsa -out CA.key 2048`
    -   Do not set a passphrase
-   Generate a CA Cert
    -   `openssl req -x509 -new -nodes -key CA.key -sha256 -days 1825 -out CA.pem`

### NGINX Config

-   Copy `data/etc/nginx/conf.d/default.conf.example` to `data/etc/nginx/conf.d/default.conf`
-   Copy `data/etc/nginx/sites/site.conf.example` to `data/etc/nginx/sites/<YOUR_HOST>.conf` where `<YOUR_HOST>` is your domain name - like `hello-world.com.conf`.
-   Edit the copied .conf file to replace all `${}` tags with your domain's configuration
    -   `${domain}` with your domain
    -   `${host}` with your server's IP address or domain
    -   `${port}` with your server's port

## Start the image

`/bin/bash start.sh`

## Add more domains

-   Copy `data/etc/nginx/sites/site.conf.example` to `data/etc/nginx/sites/<YOUR_HOST>.conf` where `<YOUR_HOST>` is your domain name - like `hello-world.com.conf`.
-   Edit the copied .conf file to replace `${DOMAIN}` with your domain

## Force immediate cert renewal

`docker exec nginx /bin/bash /app/scripts/site_certs.sh`

## Hot reload NGINX

`docker exec nginx nginx -s reload`
