#!/usr/bin/env bash
if [ -f "getenv.sh" ]; then
    source getenv.sh
fi
eval_cmd="docker run \
-d \
--restart=unless-stopped \
--name $PROJECT_DOCKER_CONTAINER_NAME \
-p 80:80 \
-p 443:443 \
-v "$(pwd)"/data/etc/nginx/sites:/etc/nginx/sites:ro \
-v "$(pwd)"/data/etc/nginx/conf.d:/etc/nginx/conf.d:ro \
-v site_certs:/etc/nginx/site_certs:rw \
-v global_certs:/etc/nginx/global_certs:rw \
$PROJECT_DOCKER_FULL_PATH \
"
eval "$eval_cmd"