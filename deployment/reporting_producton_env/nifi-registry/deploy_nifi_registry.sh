#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="108.128.10.51:2376"
export DOCKER_CERT_PATH="${PWD}/../../../credentials/production_reporting_env"

/usr/local/bin/docker-compose kill
/usr/local/bin/docker-compose down -v
/usr/local/bin/docker-compose up --build --force-recreate -d --scale scalyr=0
