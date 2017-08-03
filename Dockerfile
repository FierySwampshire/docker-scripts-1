FROM nginx:alpine
LABEL maintainer="Gopinath Rangappa"

COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN mkdir -p /var/www/docker-scripts
COPY *.sh /var/www/docker-scripts/
EXPOSE 80
