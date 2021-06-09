#!/usr/bin/env bash
set -euo pipefail

APP_NAME=${1:-argo-cheesy-parts}
APP_DOMAIN=${2:-parts.frcargonauts.org}

if ! heroku apps:info &> /dev/null; then
    heroku create argo-cheesy-parts
    heroku stack:set container
fi

heroku apps:info
echo ""

if ! heroku addons | grep -q cleardb; then
    heroku addons:create cleardb:ignite
    CLEARDB_DATABASE_URL=$(heroku config:get CLEARDB_DATABASE_URL)

    heroku config:set MYSQL_USER=$(echo "${CLEARDB_DATABASE_URL}" | sed 's/mysql:\/\/\([^:]*\).*/\1/') \
        MYSQL_PASSWORD=$(echo "${CLEARDB_DATABASE_URL}" | sed 's/mysql:\/\/[^:]*:\([^@]*\).*/\1/') \
        MYSQL_HOST=$(echo "${CLEARDB_DATABASE_URL}" | sed 's/mysql:\/\/[^:]*:[^@]*@\([^\/]*\).*/\1/') \
        MYSQL_DATABASE=$(echo "${CLEARDB_DATABASE_URL}" | sed 's/mysql:\/\/[^:]*:[^@]*@[^\/]*\/\([^?]*\).*/\1/') > /dev/null
fi

if ! heroku domains | grep -q herokudns.com; then
    heroku domains:add "${APP_DOMAIN}"
    heroku domains:wait "${APP_DOMAIN}"
    heroku domains:info "${APP_DOMAIN}" | grep cname | awk '{print $2}'
fi

heroku domains
echo ""

if ! heroku certs:info &> /dev/null; then
    heroku certs:auto:enable || true
fi
