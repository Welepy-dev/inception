FROM debian:bookworm

RUN apt update && \
	apt upgrade && \
	apt-get install -y nginx openssl && \
	rm -rf /var/lib/apt/lists/*

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx.key \
    -out /etc/ssl/certs/nginx.crt \
    -subj "/CN=login.42.fr"

RUN chown -R www-data:www-data /var/www/html

RUN sed -i 's/user  nginx;/user www-data;/' /etc/nginx/nginx.conf

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

