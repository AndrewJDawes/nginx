#!/usr/bin/env bash
if [ -f "getenv.sh" ]; then
    source getenv.sh
fi

# Attach to nginx-reverse-proxy network
network_name="nginx-reverse-proxy"
network_cmd="docker network inspect $network_name || docker network create $network_name"
eval "$network_cmd"

eval_cmd="docker run \
-d \
--restart=unless-stopped \
--name $PROJECT_DOCKER_CONTAINER_NAME \
--env CSR_REQUEST_ENDPOINT=${CSR_REQUEST_ENDPOINT-'ca-certificate-service/domain'} \
--network=$network_name \
-p 80:80 \
-p 443:443 \
-v "$(pwd)"/data/ca_certs:/app/data/ca_certs:rw \
-v "$(pwd)"/data/etc/nginx/sites:/etc/nginx/sites:ro \
-v "$(pwd)"/data/etc/nginx/conf.d:/etc/nginx/conf.d:ro \
-v site_certs:/etc/nginx/site_certs:rw \
-v global_certs:/etc/nginx/global_certs:rw \
$PROJECT_DOCKER_FULL_PATH \
"
eval "$eval_cmd"