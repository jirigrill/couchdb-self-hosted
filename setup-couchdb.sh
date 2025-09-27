#!/bin/bash

# CouchDB Setup Script for Obsidian LiveSync
# Automates the CouchDB configuration process

set -e

# Load configuration from .env file
if [ ! -f .env ]; then
    echo "Error: .env file not found"
    exit 1
fi

# Source .env file
set -a
source .env
set +a

# Check required variables
if [ -z "$COUCHDB_USER" ] || [ -z "$COUCHDB_PASSWORD" ]; then
    echo "Error: COUCHDB_USER and COUCHDB_PASSWORD must be set in .env file"
    exit 1
fi

# Configuration
COUCHDB_HOST="localhost"
COUCHDB_PORT="${COUCHDB_PORT:-5984}"
COUCHDB_URL="http://${COUCHDB_HOST}:${COUCHDB_PORT}"
DATABASE_NAME="${DATABASE_NAME:-obsidiandb}"

echo "=================================================="
echo "CouchDB Setup for Obsidian LiveSync"
echo "=================================================="
echo "Database: ${DATABASE_NAME}"
echo "User: ${COUCHDB_USER}"
echo "=================================================="

# Wait for CouchDB to be ready
echo "Waiting for CouchDB to be ready..."
for i in {1..30}; do
    if curl -s -f "${COUCHDB_URL}/" >/dev/null 2>&1; then
        echo "CouchDB is ready"
        break
    fi
    echo "Attempt $i/30 - waiting..."
    sleep 2
    if [ $i -eq 30 ]; then
        echo "Error: CouchDB failed to become ready"
        exit 1
    fi
done

# Setup single node
echo "Setting up CouchDB as single node..."
curl -s -X POST "${COUCHDB_URL}/_cluster_setup" \
    -H "Content-Type: application/json" \
    -d "{\"action\": \"enable_single_node\", \"username\": \"${COUCHDB_USER}\", \"password\": \"${COUCHDB_PASSWORD}\"}" \
    >/dev/null || echo "Single node may already be configured"

echo "Single node setup completed"

# Create database
echo "Creating database: ${DATABASE_NAME}"
HTTP_CODE=$(curl -s -w "%{http_code}" -X PUT "${COUCHDB_URL}/${DATABASE_NAME}" \
    -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" -o /dev/null)

if [ "$HTTP_CODE" = "201" ]; then
    echo "Database '${DATABASE_NAME}' created"
elif [ "$HTTP_CODE" = "412" ]; then
    echo "Database '${DATABASE_NAME}' already exists"
else
    echo "Error: Failed to create database (HTTP: $HTTP_CODE)"
    exit 1
fi

# Apply CouchDB configuration for Obsidian LiveSync
echo "Applying CouchDB configuration for Obsidian LiveSync..."

set_config() {
    local section="$1"
    local key="$2"
    local value="$3"

    echo "Setting config: [$section] $key = $value"

    HTTP_CODE=$(curl -s -w "%{http_code}" -X PUT "${COUCHDB_URL}/_node/_local/_config/${section}/${key}" \
        -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" \
        -H "Content-Type: application/json" \
        -d "\"${value}\"" -o /dev/null)

    if [ "$HTTP_CODE" != "200" ]; then
        echo "Error: Failed to set config [$section] $key (HTTP: $HTTP_CODE)"
        exit 1
    fi
}

# Configuration entries for Obsidian LiveSync
set_config "chttpd" "require_valid_user" "true"
set_config "chttpd_auth" "require_valid_user" "true"
set_config "httpd" "WWW-Authenticate" "Basic realm=\"couchdb\""
set_config "httpd" "enable_cors" "true"
set_config "chttpd" "enable_cors" "true"
set_config "chttpd" "max_http_request_size" "4294967296"
set_config "couchdb" "max_document_size" "50000000"
set_config "cors" "credentials" "true"
set_config "cors" "origins" "app://obsidian.md,capacitor://localhost,http://localhost"

echo "CouchDB configuration completed"

# Verify installation
echo "Verifying CouchDB installation..."
RESPONSE=$(curl -s "${COUCHDB_URL}/_up" -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}")

if echo "$RESPONSE" | grep -q '"status":"ok"'; then
    echo "CouchDB installation verified successfully"
else
    echo "Error: CouchDB installation verification failed"
    exit 1
fi

echo "=================================================="
echo "Setup completed successfully!"
echo "=================================================="
echo ""
echo "Next steps:"
echo "1. Access CouchDB admin: ${COUCHDB_URL}/_utils"
echo "2. Configure Obsidian LiveSync plugin with:"
echo "   - Database URL: ${COUCHDB_URL}"
echo "   - Database: ${DATABASE_NAME}"
echo "   - Username: ${COUCHDB_USER}"
echo "   - Password: [your password]"
echo ""