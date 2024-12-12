FROM alpine:3.21

# upgrade system / install apache
RUN apk upgrade --no-cache \
        && apk add --no-cache \
	nginx \
	php83-fpm \
	php83-pecl-apcu \
	php83-imap \
	php83-opcache \
	php83-pdo \
	php83-pdo_pgsql \
	php83-pecl-imagick \
	nextcloud29 \
	nextcloud29-cloud_federation_api \
	nextcloud29-comments \
	nextcloud29-default-apps \
	nextcloud29-federation \
	nextcloud29-files_reminders \
	nextcloud29-files_trashbin \
	nextcloud29-files_versions \
	nextcloud29-firstrunwizard \
	nextcloud29-pgsql \
	nextcloud29-sharebymail \
	nextcloud29-support \
	nextcloud29-systemtags \
	nextcloud29-user_status \
        s6 setpriv doas \
	# remove default php config
	&& (if [ -d /etc/php*/php-fpm.d/ ]; then rm -v /etc/php*/php-fpm.d/*; fi)

# add the custom configurations
COPY rootfs/ /

VOLUME /usr/share/webapps/nextcloud/data
VOLUME /usr/share/webapps/nextcloud/apps2
VOLUME /usr/share/webapps/logs

# server defaults to port 80
EXPOSE 80

CMD [ "/entrypoint.sh" ]
