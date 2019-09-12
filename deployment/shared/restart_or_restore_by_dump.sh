#!/usr/bin/env bash

read_var_from_env_restore() {
    echo $(cat .env-restore | grep -v -E '^#' | grep "$1" | cut -d '=' -f2)
}

extract_host() {
    echo $(echo $1 | sed 's|jdbc:postgresql://||' | sed 's|:5432||' | cut -d '/' -f1)
}

extract_db_name() {
    echo $(echo $1 | sed 's|jdbc:postgresql://||' | sed 's|:5432||' | cut -d '/' -f2)
}

if [ "$KEEP_OR_WIPE" == "wipe" ]; then
    echo "Will WIPE data and copy database from .env-restore!"

    cp ../../credentials/${CREDENTIALS_SUB_DIRECTORY}/.env-restore ../shared/restore/.env-restore

    # creating env properites
    export ENCODED_USER_PASSWORD=$(read_var_from_env_restore ENCODED_USER_PASSWORD)
    SOURCE_DATABASE_URL=$(read_var_from_env_restore SOURCE_DATABASE_URL)
    SOURCE_DATABASE_USER=$(read_var_from_env_restore SOURCE_DATABASE_USER)
    SOURCE_DATABASE_PASSWORD=$(read_var_from_env_restore SOURCE_DATABASE_PASSWORD)

    : ${SOURCE_DATABASE_URL:?"Need to set SOURCE_DATABASE_URL"}
    : ${SOURCE_DATABASE_USER:?"Need to set SOURCE_DATABASE_USER"}
    : ${SOURCE_DATABASE_PASSWORD:?"Need to set SOURCE_DATABASE_PASSWORD"}

    : ${DATABASE_URL:?"Need to set DATABASE_URL"}
    : ${POSTGRES_USER:?"Need to set POSTGRES_USER"}
    : ${POSTGRES_PASSWORD:?"Need to set POSTGRES_PASSWORD"}

    # extracting host and name from 'jdbc:postgresql://host:5432/name'
    SOURCE_HOST=$(extract_host $SOURCE_DATABASE_URL)
    DEST_HOST=$(extract_host $DATABASE_URL)
    SOURCE_DATABASE_NAME=$(extract_db_name $SOURCE_DATABASE_URL)
    DATABASE_NAME=$(extract_db_name $DATABASE_URL)

    : "${SOURCE_HOST:?SOURCE_HOST not parsed}"
    : "${DEST_HOST:?DEST_HOST not parsed}"
    : "${SOURCE_DATABASE_NAME:?SOURCE_DATABASE_NAME not parsed}"
    : "${DATABASE_NAME:?DATABASE_NAME not parsed}"

    clear_sql=$(cat<<EOF
        DROP SCHEMA IF EXISTS auth CASCADE;
        DROP SCHEMA IF EXISTS fulfillment CASCADE;
        DROP SCHEMA IF EXISTS hapifhir CASCADE;
        DROP SCHEMA IF EXISTS notification CASCADE;
        DROP SCHEMA IF EXISTS referencedata CASCADE;
        DROP SCHEMA IF EXISTS report CASCADE;
        DROP SCHEMA IF EXISTS reports CASCADE;
        DROP SCHEMA IF EXISTS requisition CASCADE;
        DROP SCHEMA IF EXISTS servicedesk CASCADE;
        DROP SCHEMA IF EXISTS stockmanagement CASCADE;
        DROP SCHEMA IF EXISTS template CASCADE;
EOF
    )

    docker system prune -a --volumes -f
    /usr/local/bin/docker-compose down -v

    echo "Removing existing schemas..." &&
    PGPASSWORD="${POSTGRES_PASSWORD}" psql -h $DEST_HOST -U $POSTGRES_USER $DATABASE_NAME -c "$clear_sql" &&

    echo "Creating dump..." &&
    PGPASSWORD=$SOURCE_DATABASE_PASSWORD pg_dump -h $SOURCE_HOST -d $SOURCE_DATABASE_NAME -U $SOURCE_DATABASE_USER -v -N topology -O > db_dump.sql &&

    echo "Restoring dump..." &&
    PGPASSWORD=$POSTGRES_PASSWORD psql -h $DEST_HOST -U $POSTGRES_USER $DATABASE_NAME < db_dump.sql &&
    ../shared/restore/after_restore.sh &&

    echo "Launching the instance..." &&
    /usr/local/bin/docker-compose up --build --force-recreate -d

    rm -f db_dump.sql
    rm -f ../shared/restore/.env-restore
else
    ../shared/restart.sh
fi
