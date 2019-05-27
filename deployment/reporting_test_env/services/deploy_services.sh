#!/usr/bin/env bash

export DOCKER_TLS_VERIFY="1"
export COMPOSE_TLS_VERSION=TLSv1_2
export DOCKER_HOST="report.test.ao.openlmis.org:2376"
export DOCKER_CERT_PATH="${PWD}/../../../credentials/test_reporting_env"
export DOCKER_COMPOSE_BIN=/usr/local/bin/docker-compose

export REPORTING_DIR_NAME=reporting

export SUPERSET_ENABLE_SSL=false
export SUPERSET_BEHIND_LOAD_BALANCER=false
export SUPERSET_LOAD_BALANCER_REDIRECT_HTTP=false
export SUPERSET_DOMAIN_NAME=report.test.ao.openlmis.org

export NIFI_ENABLE_SSL=false
export NIFI_BEHIND_LOAD_BALANCER=false
export NIFI_LOAD_BALANCER_REDIRECT_HTTP=false
export NIFI_DOMAIN_NAME=report.test.ao.openlmis.org

reportingRepo=$1

cd "$reportingRepo/$REPORTING_DIR_NAME"
$DOCKER_COMPOSE_BIN kill
$DOCKER_COMPOSE_BIN down -v
$DOCKER_COMPOSE_BIN up --build --force-recreate -d --scale scalyr=0 --scale kafka=0 --scale zookeeper=0
