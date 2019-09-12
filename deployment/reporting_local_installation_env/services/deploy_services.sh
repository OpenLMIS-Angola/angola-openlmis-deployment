#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export COMPOSE_TLS_VERSION=TLSv1_2
export DOCKER_HOST="local.ao.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/../../../credentials/local_installation_reporting_env"
export DOCKER_COMPOSE_BIN=/usr/local/bin/docker-compose

export REPORTING_DIR_NAME=reporting

# changing the conflicting port of NiFi
export NIFI_WEB_HTTP_PORT=81

distro_repo=$1

cd "$distro_repo/$REPORTING_DIR_NAME" &&
$DOCKER_COMPOSE_BIN kill &&
$DOCKER_COMPOSE_BIN down -v --remove-orphans &&

# In order to avoid generated new certificates between next deploys of ReportingStack
# we need to move them to seperate volume marked as external.
# External volumes are not removed even we use docker-compose down with -v option.
# The external volume need to be created before the docker start
# docker volume create letsencrypt-config

# The same is with data stored by database. To avoid running the whole ETL process,
# we need to create a volume for Postgres data and mark it as external,
# so that Nifi can update already persisted data.
if [ "$KEEP_OR_WIPE" == "wipe" ]; then
    echo "Will WIPE data!"
    docker volume rm pgdata
fi
docker volume create pgdata

$DOCKER_COMPOSE_BIN build &&
$DOCKER_COMPOSE_BIN up -d --scale scalyr=0
