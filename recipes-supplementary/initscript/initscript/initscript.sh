#!/bin/sh

logger "Starting basic configuration"

## Graylog configuration changes

GRAYLOG_CONF="/etc/graylog/server/server.conf"
SEC_PWD=`/usr/bin/ranpwd --alphanum --lower 96`
ROOT_PWD=`/bin/echo -n "boxsoc" | /usr/bin/tr -d '\n' | /usr/bin/sha256sum | /usr/bin/cut -d" " -f1`

if [ -f ${GRAYLOG_CONF} ]; then
	cp -r ${GRAYLOG_CONF} ${GRAYLOG_CONF}.ORIG
fi

sed -i "s/password_secret =/password_secret = ${SEC_PWD}/g" ${GRAYLOG_CONF}
sed -i "s/root_password_sha2 =/root_password_sha2 = ${ROOT_PWD}/g" ${GRAYLOG_CONF}

logger "Configuration done"

## Initial Selection

echo -n ""

## Job done, remove it from systemd services
systemctl disable initscript.service
