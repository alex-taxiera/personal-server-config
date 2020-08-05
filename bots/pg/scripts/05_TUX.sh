#!/bin/bash
set -e

DATABASE="$(< /run/secrets/TUX_DB_NAME)"
USER="$(< /run/secrets/TUX_DB_USER)"
PASSW="$(< /run/secrets/TUX_DB_PASS)"

PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
	CREATE DATABASE ${DATABASE};

	CREATE USER ${USER} WITH ENCRYPTED PASSWORD '${PASSW}';

	REVOKE ALL ON DATABASE ${DATABASE} FROM PUBLIC;
	GRANT CONNECT ON DATABASE ${DATABASE} TO ${USER};
	GRANT CONNECT ON DATABASE ${DATABASE} TO readonly;
EOSQL

PGPASSWORD="$POSTGRES_PASSWORD" psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" "${DATABASE}" <<-EOSQL
	REVOKE ALL ON SCHEMA public FROM PUBLIC;
	GRANT USAGE ON SCHEMA public TO readonly;
	GRANT USAGE ON SCHEMA public TO ${USER};

	ALTER DEFAULT PRIVILEGES IN SCHEMA public
		GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public to ${USER};

	ALTER DEFAULT PRIVILEGES IN SCHEMA public
		GRANT SELECT ON TABLES TO readonly;
	ALTER DEFAULT PRIVILEGES IN SCHEMA public
		GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO ${USER};
EOSQL
