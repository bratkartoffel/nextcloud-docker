FROM alpine:3.24

ENV NC_VERS=33 PHP_VERS=85

# upgrade system / install apache
RUN apk upgrade --no-cache \
        && apk add --no-cache \
	nginx \
	php${PHP_VERS}-fpm \
	php${PHP_VERS}-imap \
	php${PHP_VERS}-pdo_pgsql \
	php${PHP_VERS}-pecl-apcu \
	php${PHP_VERS}-pecl-imagick \
	nextcloud${NC_VERS} \
	nextcloud${NC_VERS}-activity \
	nextcloud${NC_VERS}-app_api \
	nextcloud${NC_VERS}-cloud_federation_api \
	nextcloud${NC_VERS}-comments \
	nextcloud${NC_VERS}-default-apps \
	nextcloud${NC_VERS}-federation \
	nextcloud${NC_VERS}-files_downloadlimit \
	nextcloud${NC_VERS}-files_reminders \
	nextcloud${NC_VERS}-files_trashbin \
	nextcloud${NC_VERS}-files_versions \
	nextcloud${NC_VERS}-firstrunwizard \
	nextcloud${NC_VERS}-occ \
	nextcloud${NC_VERS}-photos \
	nextcloud${NC_VERS}-pgsql \
	nextcloud${NC_VERS}-sharebymail \
	nextcloud${NC_VERS}-support \
	nextcloud${NC_VERS}-systemtags \
	nextcloud${NC_VERS}-user_status \
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
