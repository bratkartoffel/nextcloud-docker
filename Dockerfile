FROM alpine:3.20

# upgrade system / install apache
RUN apk upgrade --no-cache \
        && apk add --no-cache \
	nginx \
	php82-fpm \
	php82-pecl-apcu \
	php82-imap \
	php82-opcache \
	php82-pdo \
	php82-pdo_pgsql \
	php82-pecl-imagick \
	nextcloud \
	nextcloud-cloud_federation_api \
	nextcloud-comments \
	nextcloud-default-apps \
	nextcloud-federation \
	nextcloud-files_reminders \
	nextcloud-files_trashbin \
	nextcloud-files_versions \
	nextcloud-firstrunwizard \
	nextcloud-pgsql \
	nextcloud-sharebymail \
	nextcloud-support \
	nextcloud-systemtags \
	nextcloud-user_status \
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
