#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export COMPOSE_TLS_VERSION=TLSv1_2
export DOCKER_HOST="report.production.ao.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/../../../credentials/production_reporting_env"

export REPORTING_DIR_NAME=reporting

export SUPERSET_ENABLE_SSL=false
export SUPERSET_SSL_CERT_CHAIN=
export SUPERSET_SSL_KEY=
export SUPERSET_SSL_CERT=
export SUPERSET_DOMAIN_NAME=report.production.ao.openlmis.org

export NIFI_ENABLE_SSL=false
export NIFI_SSL_CERT_CHAIN=
export NIFI_SSL_KEY=
export NIFI_SSL_CERT=
export NIFI_DOMAIN_NAME=report.production.ao.openlmis.org
export NIFI_JVM_HEAP_MAX=2g

reportingRepo=$1

cd "$reportingRepo/$REPORTING_DIR_NAME"

export DOCKER_COMPOSE_BIN=/usr/local/bin/docker-compose
$DOCKER_COMPOSE_BIN kill
$DOCKER_COMPOSE_BIN down -v
$DOCKER_COMPOSE_BIN up --build --force-recreate -d --scale scalyr=0
