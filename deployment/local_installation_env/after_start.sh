#!/bin/bash

: ${DATABASE_URL:?"Need to set DATABASE_URL"}
: ${POSTGRES_USER:?"Need to set POSTGRES_USER"}
: ${POSTGRES_PASSWORD:?"Need to set POSTGRES_PASSWORD"}

: ${CLIENT_USERNAME:?"Need to set CLIENT_USERNAME"}
: ${CLIENT_SECRET:?"Need to set CLIENT_SECRET"}
: ${SERVICE_CLIENT_ID:?"Need to set SERVICE_CLIENT_ID"}
: ${SERVICE_CLIENT_SECRET:?"Need to set SERVICE_CLIENT_SECRET"}
: ${OL_SUPERSET_USER:?"Need to set OL_SUPERSET_USER"}
: ${OL_SUPERSET_PASSWORD:?"Need to set OL_SUPERSET_PASSWORD"}

URL=`echo ${DATABASE_URL} | sed -E 's/^jdbc\:(.+)/\1/'` # jdbc:<url>
: "${URL:?URL not parsed}"

sql=$(cat <<EOF
-- removing default clients
DELETE FROM auth.oauth_client_details WHERE clientid = 'trusted-client';
DELETE FROM auth.oauth_client_details WHERE clientid = 'user-client';

-- updating custom clients
DELETE FROM auth.oauth_client_details WHERE clientid = '${CLIENT_USERNAME}';
DELETE FROM auth.oauth_client_details WHERE clientid = '${SERVICE_CLIENT_ID}';
DELETE FROM auth.oauth_client_details WHERE clientid = '${OL_SUPERSET_USER}';
INSERT INTO auth.oauth_client_details (clientId,authorities,authorizedGrantTypes,clientSecret,scope,resourceIds) VALUES ('${CLIENT_USERNAME}','TRUSTED_CLIENT','client_credentials','${CLIENT_SECRET}','read,write','hapifhir,notification,reports,diagnostics,auth,requisition,referencedata,stockmanagement,angola-reference-ui,fulfillment');
INSERT INTO auth.oauth_client_details (clientId,authorities,authorizedGrantTypes,clientSecret,scope,resourceIds) VALUES ('${SERVICE_CLIENT_ID}','TRUSTED_CLIENT','password','${SERVICE_CLIENT_SECRET}','read,write','hapifhir,notification,reports,diagnostics,auth,requisition,referencedata,stockmanagement,angola-reference-ui,fulfillment');
INSERT INTO auth.oauth_client_details (clientId,authorities,authorizedGrantTypes,clientSecret,scope,resourceIds) VALUES ('${OL_SUPERSET_USER}','TRUSTED_CLIENT','authorization_code','${OL_SUPERSET_PASSWORD}','read,write','hapifhir,notification,reports,diagnostics,auth,requisition,referencedata,stockmanagement,angola-reference-ui,fulfillment');

-- OLMIS-6078: it will not be required in OL_NOTIFICATION_VERSION >= 4.2.0
INSERT INTO notification.user_contact_details (referencedatauserid, allownotify, email, emailVerified)
    SELECT '35316636-6264-6331-2d34-3933322d3462', true, 'example@mail.com', true
WHERE
    NOT EXISTS (
        SELECT referencedatauserid FROM notification.user_contact_details WHERE referencedatauserid = '35316636-6264-6331-2d34-3933322d3462'
    );
EOF
)

echo "Executing inserting sensitive data!!!!"

PGPASSWORD="${POSTGRES_PASSWORD}" psql ${URL} -U ${POSTGRES_USER} -c "$sql"

echo "Done inserting sensitive data!!!!"
