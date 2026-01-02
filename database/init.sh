#!/bin/bash

# WonderWorld Learning Adventure - Database Initialization Script
# This script creates the database and runs the schema

set -e

# Load environment variables
if [ -f ../.env ]; then
    export $(cat ../.env | grep -v '#' | awk '/=/ {print $1}')
fi

# Default values
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-wonderworld_learning}
DB_USER=${DB_USER:-efeobukohwo}

echo "🌟 WonderWorld Learning Adventure - Database Setup 🌟"
echo "========================================================"

# Create database if it doesn't exist
echo "📦 Creating database '$DB_NAME'..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -tc "SELECT 1 FROM pg_database WHERE datname = '$DB_NAME'" | grep -q 1 || \
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DB_NAME"

echo "✅ Database created or already exists"

# Run schema
echo "🏗️  Running schema migrations..."
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f schema.sql

echo "========================================================"
echo "✨ Database setup complete!"
echo "   Database: $DB_NAME"
echo "   Host: $DB_HOST:$DB_PORT"
echo "========================================================"
