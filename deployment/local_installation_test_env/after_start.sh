#!/bin/bash

: ${DATABASE_URL:?"Need to set DATABASE_URL"}
: ${POSTGRES_USER:?"Need to set POSTGRES_USER"}
: ${POSTGRES_PASSWORD:?"Need to set POSTGRES_PASSWORD"}

: ${UI_CLIENT_SECRET:?"Need to set UI_CLIENT_SECRET"}
: ${AUTH_SERVER_CLIENT_SECRET:?"Need to set AUTH_SERVER_CLIENT_SECRET"}
: ${OL_SUPERSET_PASSWORD:?"Need to set OL_SUPERSET_PASSWORD"}

URL=`echo ${DATABASE_URL} | sed -E 's/^jdbc\:(.+)/\1/'` # jdbc:<url>
: "${URL:?URL not parsed}"

sql=$(cat <<EOF
DELETE FROM auth.oauth_client_details WHERE clientid = 'trusted-client';
DELETE FROM auth.oauth_client_details WHERE clientid = 'user-client';
DELETE FROM auth.oauth_client_details WHERE clientid = 'angola-client';
DELETE FROM auth.oauth_client_details WHERE clientid = 'angola-ui-client';
DELETE FROM auth.oauth_client_details WHERE clientid = 'superset';

INSERT INTO auth.oauth_client_details (clientId,authorities,authorizedGrantTypes,clientSecret,scope,resourceIds) VALUES ('angola-client','TRUSTED_CLIENT','client_credentials','${UI_CLIENT_SECRET}','read,write','hapifhir,notification,reports,diagnostics,auth,requisition,referencedata,stockmanagement,angola-reference-ui,fulfillment');
INSERT INTO auth.oauth_client_details (clientId,authorities,authorizedGrantTypes,clientSecret,scope,resourceIds) VALUES ('angola-ui-client','TRUSTED_CLIENT','password','${AUTH_SERVER_CLIENT_SECRET}','read,write','hapifhir,notification,reports,diagnostics,auth,requisition,referencedata,stockmanagement,angola-reference-ui,fulfillment');
INSERT INTO auth.oauth_client_details (clientId,authorities,authorizedGrantTypes,clientSecret,scope,resourceIds) VALUES ('superset','TRUSTED_CLIENT','authorization_code','${OL_SUPERSET_PASSWORD}','read,write','hapifhir,notification,reports,diagnostics,auth,requisition,referencedata,stockmanagement,angola-reference-ui,fulfillment');
EOF
)

echo "Executing inserting sensitive data!!!!"

PGPASSWORD="${POSTGRES_PASSWORD}" psql ${URL} -U ${POSTGRES_USER} -c "$sql"

echo "Done inserting sensitive data!!!!"
