#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="172.18.130.75:2376"
export CREDENTIALS_SUB_DIRECTORY="test_reporting_on_prem_env"
export DOCKER_CERT_PATH="${PWD}/../../credentials/${CREDENTIALS_SUB_DIRECTORY}"

/usr/local/bin/docker-compose pull

../shared/restart_or_restore.sh $1
