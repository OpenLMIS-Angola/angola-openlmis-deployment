#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export COMPOSE_TLS_VERSION=TLSv1_2
export DOCKER_HOST="report.test.siglofa.sisangola.org:2376"
export DOCKER_CERT_PATH="${PWD}/../../../credentials/test_reporting_env"
export DOCKER_COMPOSE_BIN=/usr/local/bin/docker-compose

export REPORTING_DIR_NAME=reporting

export SUPERSET_ENABLE_SSL=false
export SUPERSET_BEHIND_LOAD_BALANCER=false
export SUPERSET_LOAD_BALANCER_REDIRECT_HTTP=false
#export SUPERSET_DOMAIN_NAME=report.test.ao.openlmis.org

export NIFI_ENABLE_SSL=false
export NIFI_BEHIND_LOAD_BALANCER=false
export NIFI_LOAD_BALANCER_REDIRECT_HTTP=false
#export NIFI_DOMAIN_NAME=report.test.ao.openlmis.org


distro_repo=$1
#init_with_lets_encrypt_sh_path="../../deployment/shared/init_with_lets_encrypt.sh"

# In order to avoid generated new certificates between next deploys of ReportingStack
# we need to move them to seperate volume marked as external.
# External volumes are not removed even we use docker-compose down with -v option.
# The external volume need to be created before the docker start
#docker volume create letsencrypt-config
# The same is with data stored by database. To avoid running the whole ETL process,
# we need to create a volume for Postgres data and mark it as external,
# so that Nifi can update already persisted data.
docker volume create pgdata

cd "$distro_repo/$REPORTING_DIR_NAME" &&
$DOCKER_COMPOSE_BIN kill &&
$DOCKER_COMPOSE_BIN down -v --remove-orphans &&

/usr/local/bin/docker-compose build &&

$DOCKER_COMPOSE_BIN up -d --scale scalyr=0
