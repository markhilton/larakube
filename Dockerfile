FROM alpine:3.5

COPY laravel-project /var/www/
COPY infrastructure  /var/www/infrastructure

RUN chmod -R 777 /var/www/storage && \
	chmod -R 777 /var/www/bootstrap/cache

RUN chown -R 9000:9000 /var/www

WORKDIR /var/www
