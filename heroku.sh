#!/usr/bin/env bash
set -euo pipefail

APP_NAME=${1:-argo-cheesy-parts}

if ! heroku apps:info > /dev/null; then
    heroku create argo-cheesy-parts
    heroku stack:set --app "${APP_NAME}" container
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
