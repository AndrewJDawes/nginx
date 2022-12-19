#!/usr/bin/env bash
# Generate global certs, dummy certs, then start nginx in foreground
/app/scripts/global_certs.sh && \
/app/scripts/site_certs.sh && \
exec nginx -g "daemon off;"
