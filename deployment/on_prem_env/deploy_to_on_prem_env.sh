#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="154.116.255.94:2376"
export CREDENTIALS_SUB_DIRECTORY="on_prem_env"
export DOCKER_CERT_PATH="${PWD}/../../credentials/${CREDENTIALS_SUB_DIRECTORY}"

/usr/local/bin/docker-compose pull

../shared/restart_or_restore.sh $1
