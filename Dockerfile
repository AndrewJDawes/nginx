FROM nginx:1.23.2-alpine

EXPOSE 80 443

WORKDIR /app
RUN apk update
RUN apk add bash
RUN apk add --no-cache openssl

COPY cronfile /etc/cron.d/cronfile
# Giving permission to crontab file
RUN chmod 0644 /etc/cron.d/cronfile
# Registering file to crontab
RUN crontab /etc/cron.d/cronfile

COPY includes /etc/nginx/includes
COPY scripts /app/scripts

RUN chmod +x /app/scripts/global_certs.sh
RUN chmod +x /app/scripts/site_certs.sh
RUN chmod +x /app/scripts/nginx.sh

# ENTRYPOINT ["nginx"]
CMD ["/app/scripts/nginx.sh"]
