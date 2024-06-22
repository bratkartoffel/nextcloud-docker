<?php
$_unset = array(
    'WITH_SSL',
    'WITH_HEADERS',
    'WITH_PHP',
    'HTTP_X_FORWARDED_FOR',
    'HTTP_VIA',
    'HTTP_X_FORWARDED_PROTO',
    'LS_COLORS',
    'MYSQL_ENV_GPG_KEYS',
    'MYSQL_NAME',
    'GID',
    'HPKP',
    'UID',
    'DEBIAN_FRONTEND',
    'MYSQL_ENV_USR_ID',
    'MYSQL_ENV_GRP_ID',
    'TERM'
);

if (isset($_SERVER['WITH_SSL'])) {
    $_SERVER['HTTPS'] = 'on';
    $_SERVER['SERVER_PORT'] = '443';
    $_SERVER['REQUEST_SCHEME'] = 'https';
}

if (array_key_exists('HOSTNAME', $_SERVER) && preg_match('/^172\.(16|17|18|19|2\d|30|31)\./', $_SERVER['SERVER_NAME'])) {
    $_SERVER['SERVER_NAME'] = $_SERVER['HOSTNAME'];
}

if (array_key_exists('HTTP_X_FORWARDED_FOR', $_SERVER)) {
    $_SERVER['REMOTE_ADDR'] = trim(explode(',', $_SERVER['HTTP_X_FORWARDED_FOR'])[0]);
}

foreach ($_unset as $i) {
    if (array_key_exists($i, $_SERVER)) {
        unset($_SERVER[$i]);
    }
}
unset($_unset);
