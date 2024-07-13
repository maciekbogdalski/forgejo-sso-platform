#!/bin/bash

set -e

database_health_check() {
  echo "Checking database health"
  while ! pg_isready -h ${GRAFANA_DB_HOST} -p 5432 -U ${GRAFANA_DB_USER}; do
    echo "Waiting for database to be ready..."
    sleep 5
  done
}

wait_for_keycloak() {
  echo "Waiting for Keycloak and VCC realm"
  while ! curl -s https://auth.vcc.local/realms/vcc > /dev/null; do
    echo "Waiting for Keycloak..."
    sleep 5
  done
}

add_system_certificate() {
  echo "Adding system certificate"
  cp /certs/traefik.crt /usr/local/share/ca-certificates/traefik.crt
  update-ca-certificates
}

set_environment_variables() {
  echo "Setting environment variables for Keycloak OAuth"
  export GF_AUTH_GENERIC_OAUTH_NAME=Keycloak
  export GF_AUTH_GENERIC_OAUTH_ENABLED=true
  export GF_AUTH_GENERIC_OAUTH_CLIENT_ID=grafana
  export GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET=your_client_secret
  export GF_AUTH_GENERIC_OAUTH_AUTH_URL=https://auth.vcc.local/realms/vcc/protocol/openid-connect/auth
  export GF_AUTH_GENERIC_OAUTH_TOKEN_URL=https://auth.vcc.local/realms/vcc/protocol/openid-connect/token
  export GF_AUTH_GENERIC_OAUTH_API_URL=https://auth.vcc.local/realms/vcc/protocol/openid-connect/userinfo
  export GF_SERVER_ROOT_URL=https://mon.vcc.local
}

database_health_check
wait_for_keycloak
add_system_certificate
set_environment_variables

exec grafana-server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini
