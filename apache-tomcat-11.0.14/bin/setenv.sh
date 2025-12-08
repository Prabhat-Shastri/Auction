#!/bin/sh
# Database environment variables for ThriftShop application
# This file loads variables from .env file in the project root

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
# Go up to project root (assuming setenv.sh is in apache-tomcat-11.0.14/bin/)
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"
ENV_FILE="$PROJECT_ROOT/.env"

# Load .env file if it exists
if [ -f "$ENV_FILE" ]; then
    # Read .env file and export variables (skip comments and empty lines)
    set -a
    . "$ENV_FILE"
    set +a
else
    # Fallback to defaults if .env doesn't exist
    export DB_HOST=${DB_HOST:-localhost}
    export DB_PORT=${DB_PORT:-3306}
    export DB_NAME=${DB_NAME:-thriftShop}
    export DB_USER=${DB_USER:-root}
    export DB_PASS=${DB_PASS:-12345}
fi
