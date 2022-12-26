#!/usr/bin/env bash
# Generate global certs, dummy certs, start cron to issue/renew certs, start nginx in foreground
/app/scripts/global_certs.sh && \
/app/scripts/site_certs.sh && \
crond -b -L /app/cron.log && \
exec nginx -g "daemon off;"
