# Use a multi-stage build
# Stage 1: Build the PostgreSQL client from Debian base
FROM debian:stable-slim as build
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Stage 2: Use Forgejo image and copy necessary files
FROM codeberg.org/forgejo/forgejo:1.21

# Copy the PostgreSQL client tools
COPY --from=build /usr/bin/psql /usr/bin/psql
COPY --from=build /usr/lib/x86_64-linux-gnu/libpq.so.5 /usr/lib/x86_64-linux-gnu/libpq.so.5

# Copy custom entrypoint
COPY entrypoint.sh /entrypoint.sh

# Make entrypoint executable
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]
