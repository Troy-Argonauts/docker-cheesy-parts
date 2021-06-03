#!/usr/bin/env bash
set -euo pipefail

# Set the MySQL connection details from env vars
jq --arg MYSQL_HOST "${MYSQL_HOST:-localhost}" '.global.db_host = $MYSQL_HOST' config.json | sponge config.json
jq --arg MYSQL_DATABASE "$MYSQL_DATABASE" '.global.db_database = $MYSQL_DATABASE' config.json | sponge config.json
jq --arg MYSQL_USER "$MYSQL_USER" '.global.db_user = $MYSQL_USER' config.json | sponge config.json
jq --arg MYSQL_PASSWORD "$MYSQL_PASSWORD" '.dev.db_password = $MYSQL_PASSWORD' config.json | sponge config.json

# Wait for MySQL and then migrate it
/wait-for-it.sh ${MYSQL_HOST:-localhost}:3306
# https://github.com/Team254/cheesy-parts/issues/20
bundle exec rake db:migrate || true
bundle exec rake db:migrate

# Execute the command, trapping the output
COMMAND=${1:-start}
{ OUTPUT=$(ruby parts_server_control.rb ${COMMAND} | tee /dev/fd/3); } 3>&1

# If starting the server, wait on the PID in the output
if [[ "${COMMAND}" == "start" ]]; then
    PID=$(echo "${OUTPUT}" | sed "s/.*pid \([0-9]\+\) started.*/\1/")
    tail --pid="${PID}" -f /dev/null
fi
