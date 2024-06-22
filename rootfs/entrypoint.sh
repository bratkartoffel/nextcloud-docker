#!/bin/ash

# exit when any command fails
set -o errexit -o pipefail

# configuration
readonly APP_HOMEDIR=/usr/share/webapps/nextcloud
readonly APP_LOGDIR="$APP_HOMEDIR"/../logs
readonly APP_TMPDIR="$APP_HOMEDIR"/../tmp

: "${APP_UMASK:=027}"
: "${APP_UID:=509}"
: "${APP_GID:=509}"
: "${APP_USER:=app}"
: "${APP_GROUP:=app}"
: "${APP_PHP_CONF_DIR:=/etc/php}"
: "${SMTPHOST:=localhost}"
: "${SERVERNAME:=localhost}"

export APP_HOMEDIR APP_LOGDIR APP_TMPDIR SMTPHOST SERVERNAME

copyAndApplyVariables() {
  local source_dir="$1/"
  local target_dir="$2"

  for source_file in $( find "$source_dir" -type f ); do
    local target_file="$target_dir/${source_file:${#source_dir}}"
    local dest_dir="$(dirname $target_file)"
    if [[ ! -d "$dest_dir" ]]; then
      mkdir -v $dest_dir
    fi

    echo ">>> $source_file -> $target_file"
    sed -e "s@{{APP_LOGDIR}}@$APP_LOGDIR@" \
      -e "s@{{APP_TMPDIR}}@$APP_TMPDIR@" \
      -e "s@{{APP_HOMEDIR}}@$APP_HOMEDIR@" \
      "$source_file" >"$target_file"
  done
}

# invoked as root, add user and prepare container
if [ "$(id -u)" -eq 0 ]; then
  echo ">> removing default user and group ($APP_USER)"
  if getent passwd "$APP_USER" >/dev/null; then deluser "$APP_USER"; fi
  if getent group "$APP_GROUP" >/dev/null; then delgroup "$APP_GROUP"; fi

  echo ">> adding unprivileged user (uid: $APP_UID / gid: $APP_GID)"
  addgroup -g "$APP_GID" "$APP_GROUP"
  adduser -HD -h "$APP_HOMEDIR" -s /sbin/nologin -G "$APP_GROUP" -u "$APP_UID" -k /dev/null "$APP_USER"

  echo ">> installing configuration"
  if [ -x /usr/sbin/php-fpm81 ]; then
    copyAndApplyVariables $APP_PHP_CONF_DIR /etc/php81
    APP_PHP_CONF_DIR=/etc/php81
  elif [ -x /usr/sbin/php-fpm82 ]; then
    copyAndApplyVariables $APP_PHP_CONF_DIR /etc/php82
    APP_PHP_CONF_DIR=/etc/php82
  elif [ -x /usr/sbin/php-fpm83 ]; then
    copyAndApplyVariables $APP_PHP_CONF_DIR /etc/php83
    APP_PHP_CONF_DIR=/etc/php83
  else
    echo ">>> no supported version of php found"
    rm -rv /etc/s6/php-fpm
  fi

  echo ">> fixing permissions"
  install -dm 2750 -o "$APP_UID" -g "$APP_GID"   "$APP_HOMEDIR"
  install -dm 0750 -o "$APP_UID" -g "$APP_GID"   "/tmp/nginx"
  install -dm 0770 -o root -g "$APP_GID"         "$APP_LOGDIR"
  install -dm 0770 -o "$APP_UID" -g "$APP_GID"   "$APP_TMPDIR"
  install -dm 0750 -o "$APP_UID" -g "$APP_GID"   "$APP_PHP_CONF_DIR"
  install -dm 0750 -o "$APP_UID" -g "$APP_GID"   /run/app
  chown -R "$APP_UID":"$APP_GID" "$APP_PHP_CONF_DIR" "$APP_LOGDIR" "$APP_TMPDIR" /etc/s6

  echo ">> create link for syslog redirection"
  install -dm 0750 -o "$APP_USER" -g "$APP_GROUP" /run/syslogd
  [[ -h /dev/log ]] && rm -v /dev/log
  ln -sfv /run/syslogd/syslogd.sock /dev/log

  # WORKAROUND for `setpriv: libcap-ng is too old for "all" caps`, previously "-all" was used here
  # create a list to drop all capabilities supported by current kernel
  # taken from https://github.com/SinusBot/docker/commit/1af523e7bd79ed91d4fd0304aea13f34f2238b2f
  cap_prefix="-cap_"
  caps="$cap_prefix$(seq -s ",$cap_prefix" 0 $(cat /proc/sys/kernel/cap_last_cap))"

  # drop privileges and re-execute this script unprivileged
  echo ">> dropping privileges"
  export HOME="$APP_HOMEDIR" USER="$APP_USER" LOGNAME="$APP_USER" PATH="/usr/local/bin:/bin:/usr/bin"
  exec /usr/bin/setpriv --reuid="$APP_USER" --regid="$APP_GROUP" --init-groups --inh-caps=$caps "$0" "$@"
fi

# tighten umask for newly created files / dirs
echo ">> changing umask to $APP_UMASK"
umask "$APP_UMASK"

echo ">> starting application"
exec /bin/s6-svscan /etc/s6

# vim: set ft=bash ts=2 sts=2 expandtab:

