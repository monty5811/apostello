#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
CREATE USER apostello;
CREATE DATABASE apostello;
GRANT ALL PRIVILEGES ON DATABASE apostello TO apostello;
EOSQL
