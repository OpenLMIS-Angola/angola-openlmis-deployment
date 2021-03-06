#!/bin/bash

: ${DATABASE_URL:?"Need to set DATABASE_URL"}
: ${POSTGRES_USER:?"Need to set POSTGRES_USER"}
: ${POSTGRES_PASSWORD:?"Need to set POSTGRES_PASSWORD"}

: ${ENCODED_USER_PASSWORD:?"Need to set ENCODED_USER_PASSWORD"}
: ${CLIENT_USERNAME:?"Need to set CLIENT_USERNAME"}
: ${CLIENT_SECRET:?"Need to set CLIENT_SECRET"}
: ${SERVICE_CLIENT_ID:?"Need to set SERVICE_CLIENT_ID"}
: ${SERVICE_CLIENT_SECRET:?"Need to set SERVICE_CLIENT_SECRET"}
: ${SUPERSET_CLIENT:?"Need to set SUPERSET_CLIENT"}
: ${SUPERSET_CLIENT_REDIRECT_URI:?"Need to set SUPERSET_CLIENT_REDIRECT_URI"}

URL=`echo ${DATABASE_URL} | sed -E 's/^jdbc\:(.+)/\1/'` # jdbc:<url>
: "${URL:?URL not parsed}"

sql=$(cat <<EOF
UPDATE auth.auth_users SET password = '${ENCODED_USER_PASSWORD}';
UPDATE auth.auth_users SET password = '${ENCODED_SUPERSET_USER_PASSWORD}' WHERE username = 'superset';
UPDATE notification.user_contact_details SET email = SUBSTR(md5(random()::text), 1, 10) || '@example.com';
UPDATE auth.oauth_client_details SET clientsecret = '${SERVICE_CLIENT_SECRET}' WHERE clientid = 'angola-client';
UPDATE auth.oauth_client_details SET clientsecret = '${CLIENT_SECRET}' WHERE clientid = 'angola-ui-client';
UPDATE auth.oauth_client_details SET clientsecret = '${SUPERSET_CLIENT_SECRET}', redirecturi = '${SUPERSET_CLIENT_REDIRECT_URI}' WHERE clientid = '${SUPERSET_CLIENT}';
EOF
)

until PGPASSWORD="${POSTGRES_PASSWORD}" psql ${URL} -U ${POSTGRES_USER} -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 5
done

echo "Executing clearing sensitive data!!!!"

PGPASSWORD="${POSTGRES_PASSWORD}" psql ${URL} -U ${POSTGRES_USER} -c "$sql"

echo "Done clearing sensitive data!!!!"