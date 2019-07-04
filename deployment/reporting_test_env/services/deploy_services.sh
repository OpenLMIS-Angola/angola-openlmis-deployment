#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export COMPOSE_TLS_VERSION=TLSv1_2
export DOCKER_HOST="report.test.ao.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/../../../credentials/test_reporting_env"
export DOCKER_COMPOSE_BIN=/usr/local/bin/docker-compose

export REPORTING_DIR_NAME=reporting

distro_repo=$1
init_with_lets_encrypt_sh_path="../../deployment/shared/init_with_lets_encrypt.sh"

cd "$distro_repo/$REPORTING_DIR_NAME" &&
$DOCKER_COMPOSE_BIN kill &&
$DOCKER_COMPOSE_BIN down -v --remove-orphans &&

/usr/local/bin/docker-compose build &&
. $init_with_lets_encrypt_sh_path &&

$DOCKER_COMPOSE_BIN up --scale scalyr=0 --scale kafka=0 --scale zookeeper=0 --scale consul=0
