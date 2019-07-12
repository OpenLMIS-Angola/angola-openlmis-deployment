#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="development.ao.openlmis.org:2376"
export CREDENTIALS_SUB_DIRECTORY="dev_env"
export DOCKER_CERT_PATH="${PWD}/../../credentials/${CREDENTIALS_SUB_DIRECTORY}"

/usr/local/bin/docker-compose pull

../shared/tmp_run.sh $1

../shared/superset_rights/insert_superset_rights.sh