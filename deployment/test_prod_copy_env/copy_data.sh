#!/bin/bash

set -e

CONF_FILE="$1"

source "$CONF_FILE"

echo "Creating dump from $SOURCE_HOST"

PGPASSWORD=$SOURCE_PASSWORD pg_dump -c -h $SOURCE_HOST -U $SOURCE_USER $SOURCE_DATABASE > dump.sql

echo "Loading dump into $TARGET_HOST"

#PGPASSWORD=$TARGET_PASSWORD psql -h $TARGET_HOST -U $TARGET_USER $TARGET_DATABASE < dump.sql

echo "Done"
