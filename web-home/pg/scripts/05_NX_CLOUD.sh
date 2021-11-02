#!/bin/bash
set -e

DATABASE="$(< /run/secrets/NX_CLOUD_DB_NAME)"
DATABASE_USER="$DATABASE"_user
USER="$(< /run/secrets/NX_CLOUD_DB_USER)"
PASSW="$(< /run/secrets/NX_CLOUD_DB_PASS)"
READONLY=$READONLY_ROLE

PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	CREATE DATABASE ${DATABASE};
	CREATE ROLE ${DATABASE_USER};

	CREATE USER ${USER} WITH ENCRYPTED PASSWORD '${PASSW}';

	GRANT ${DATABASE_USER} TO ${USER};
	GRANT ${DATABASE_USER} TO ${READONLY};

	REVOKE ALL ON DATABASE ${DATABASE} FROM PUBLIC;
	GRANT CONNECT ON DATABASE ${DATABASE} TO ${DATABASE_USER};
EOSQL

PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" "${DATABASE}" <<-EOSQL
	REVOKE ALL ON SCHEMA public FROM PUBLIC;
	GRANT USAGE, CREATE ON SCHEMA public TO ${DATABASE_USER};

	ALTER DEFAULT PRIVILEGES IN SCHEMA public
		GRANT USAGE, SELECT ON SEQUENCES TO ${DATABASE_USER};
	ALTER DEFAULT PRIVILEGES IN SCHEMA public
		GRANT SELECT ON TABLES TO ${READONLY};
	ALTER DEFAULT PRIVILEGES IN SCHEMA public
		GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${USER};
EOSQL
