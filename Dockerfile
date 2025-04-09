FROM alpine:3.21

ARG NC_VERSION=30

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
	nextcloud${NC_VERSION} \
	nextcloud${NC_VERSION}-activity \
	nextcloud${NC_VERSION}-cloud_federation_api \
	nextcloud${NC_VERSION}-comments \
	nextcloud${NC_VERSION}-default-apps \
	nextcloud${NC_VERSION}-federation \
	nextcloud${NC_VERSION}-files_downloadlimit \
	nextcloud${NC_VERSION}-files_reminders \
	nextcloud${NC_VERSION}-files_trashbin \
	nextcloud${NC_VERSION}-files_versions \
	nextcloud${NC_VERSION}-firstrunwizard \
	nextcloud${NC_VERSION}-occ \
	nextcloud${NC_VERSION}-photos \
	nextcloud${NC_VERSION}-pgsql \
	nextcloud${NC_VERSION}-sharebymail \
	nextcloud${NC_VERSION}-support \
	nextcloud${NC_VERSION}-systemtags \
	nextcloud${NC_VERSION}-user_status \
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
