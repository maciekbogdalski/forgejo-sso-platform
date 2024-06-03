#!/bin/sh

# as the cli does not run as root
# you need to wrap the forgejo command to run as the `git` user
forgejo_cli() {
  # TODO
}

# TODO wait until database is alive (port 5432 replies)

# TODO prepare database (`forgejo migrate` cli command)

# TODO create admin user (if it does not exists already)
# use `forgejo admin user list` and `forgejo admin user create`

# start forgejo (in background)
/bin/s6-svscan /etc/s6 "$@" &

# TODO wait until forgejo is active (use curl, check for 200 code)

# TODO wait until authentication server is alive (use curl, check for 200 code)

# TODO wait until https://auth.vcc.local/realms/vcc is alive (use curl, check for 200 code)

# wait until self-signed certificate file exists
until [ -f /usr/local/share/ca-certificates/server.crt ]; do
  echo 'Waiting for certificate'
  sleep 1
done

# TODO update the system list of accepted CA certificates

#
# Download from keycloak forgejo's client id and secret 
#
keycloakAdminToken() {
  curl -k -X POST https://auth.vcc.local/realms/master/protocol/openid-connect/token \
    --data-urlencode "username=admin" \
    --data-urlencode "password=admin" \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'client_id=admin-cli' | jq -r '.access_token'
}
forgejo_client_id=$(curl -k -H "Authorization: Bearer $(keycloakAdminToken)" https://auth.vcc.local/admin/realms/vcc/clients?clientId=forgejo | jq -r '.[0].id')
forgejo_client_secret=$(curl -k -H "Authorization: Bearer $(keycloakAdminToken)" -X POST https://auth.vcc.local/admin/realms/vcc/clients/${forgejo_client_id}/client-secret | jq -r '.value')

# TODO maybe it's not that cool to put secrets in your logs :)
echo "Forgejo client id in keycloak is ${forgejo_client_id}"
echo "Forgejo client secret in keycloak is ${forgejo_client_secret}"

# TODO setup authentication (if it does not exist)
# use `forgejo admin auth add-oauth`
#   --auto-discover-url is https://auth.vcc.local/realms/vcc/.well-known/openid-configuration
#   --provider is openidConnect

# wait forever
wait