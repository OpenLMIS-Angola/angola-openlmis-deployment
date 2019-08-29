#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="18.200.96.202:2376"
export DOCKER_CERT_PATH="${PWD}/../../credentials/uat2_env"

/usr/local/bin/docker-compose pull

../shared/restart_or_restore.sh $1
