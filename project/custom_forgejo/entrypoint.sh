#!/bin/bash

set -e

forgejo_cli() {
  # Function to interact with Forgejo CLI
  echo "Running forgejo_cli function"
  # Add your CLI commands here
}

database_health_check() {
  # Function to check the health of the database
  echo "Checking database health"
  while ! PGPASSWORD=${FORGEJO_DB_PASSWD} psql -h ${FORGEJO_DB_HOST} -U ${FORGEJO_DB_USER} -d ${FORGEJO_DB_NAME} -c '\q'; do
    echo "Waiting for database to be ready..."
    sleep 5
  done
  echo "Database is ready!"
}

run_database_migration() {
  # Function to run database migration
  echo "Running database migration"
  /app/forgejo migrate
}

create_admin_user() {
  # Function to create the administrator user
  echo "Creating administrator user"
  /app/forgejo admin create --username admin --password ${ADMIN_PASSWORD} --email admin@example.com --must-change-password false
}

wait_for_forgejo() {
  # Function to wait for Forgejo to be alive
  echo "Waiting for Forgejo to be alive"
  while ! curl -s http://localhost:3000 > /dev/null; do
    echo "Waiting for Forgejo..."
    sleep 5
  done
}

wait_for_keycloak() {
  # Function to wait for Keycloak and VCC realm to be available
  echo "Waiting for Keycloak and VCC realm"
  while ! curl -s https://auth.vcc.local/realms/vcc > /dev/null; do
    echo "Waiting for Keycloak..."
    sleep 5
  done
}

add_system_certificate() {
  # Function to add the certificate to the system certificates
  echo "Adding system certificate"
  cp /certs/traefik.crt /usr/local/share/ca-certificates/traefik.crt
  update-ca-certificates
}

create_openid_client() {
  # Function to create the OpenID client
  echo "Creating OpenID client"
  forgejo_cli create-client --name forgejo --redirect-uri https://git.vcc.local/* --client-id forgejo --auth-uri https://auth.vcc.local/auth
}

# Call functions
forgejo_cli
database_health_check
run_database_migration
create_admin_user
wait_for_forgejo
wait_for_keycloak
add_system_certificate
create_openid_client

# Execute the main process
exec "$@"
