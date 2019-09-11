#!/usr/bin/env bash

read_var_from_settings_env() {
    echo $(cat settings.env | grep "$1" | cut -d '=' -f2)
}

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="local.ao.openlmis.org:2376"
export CREDENTIALS_SUB_DIRECTORY="local_installation_test_env"
export DOCKER_CERT_PATH="${PWD}/../../credentials/${CREDENTIALS_SUB_DIRECTORY}"

/usr/local/bin/docker-compose pull

export DATABASE_URL=$(read_var_from_settings_env DATABASE_URL)
export POSTGRES_USER=$(read_var_from_settings_env POSTGRES_USER)
export POSTGRES_PASSWORD=$(read_var_from_settings_env POSTGRES_PASSWORD)
export UI_CLIENT_SECRET=$(read_var_from_settings_env auth.server.clientSecret)
export AUTH_SERVER_CLIENT_SECRET=$(read_var_from_settings_env AUTH_SERVER_CLIENT_SECRET)
export OL_SUPERSET_PASSWORD=$(read_var_from_settings_env OL_SUPERSET_PASSWORD)

. after_start.sh &&

../shared/restart.sh $1
