#!/bin/sh

# TODO wait until authentication server is alive (use curl, check for 200 code)

# TODO wait until https://auth.vcc.local/realms/vcc is alive (use curl, check for 200 code)

# wait until self-signed certificate file exists
until [ -f /usr/local/share/ca-certificates/server.crt ]; do
  echo 'Waiting for certificate'
  sleep 1
done

# TODO update the system list of accepted CA certificates

#
# Download from keycloak grafana's client id and secret 
#
keycloakAdminToken() {
  curl -k -X POST https://auth.vcc.local/realms/master/protocol/openid-connect/token \
    --data-urlencode "username=admin" \
    --data-urlencode "password=admin" \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'client_id=admin-cli' | jq -r '.access_token'
}

grafana_client_id=$(curl -k -H "Authorization: Bearer $(keycloakAdminToken)" https://auth.vcc.local/admin/realms/vcc/clients?clientId=grafana | jq -r '.[0].id')
grafana_client_secret=$(curl -k -H "Authorization: Bearer $(keycloakAdminToken)" -X POST https://auth.vcc.local/admin/realms/vcc/clients/${grafana_client_id}/client-secret | jq -r '.value')

# TODO maybe it's not that cool to put secrets in your logs :)
echo "Grafana client id in keycloak is ${grafana_client_id}"
echo "Grafana client secret in keycloak is ${grafana_client_secret}"

# TODO setup authentication

# relaunch original
exec /run.sh "$@"
