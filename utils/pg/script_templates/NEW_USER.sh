#!/bin/bash
set -e

ADMIN_USER="$(< /run/secrets/ADMIN_USER)"
ADMIN_PASS="$(< /run/secrets/ADMIN_PASS)"

USER="$(< /run/secrets/USER)"
PASSW="$(< /run/secrets/PASS)"

PGPASSWORD="$ADMIN_PASS" psql -v ON_ERROR_STOP=1 --username "$ADMIN_USER" <<-EOSQL
  CREATE USER ${USER} WITH ENCRYPTED PASSWORD '${PASSW}';
	GRANT readonly TO ${USER};
EOSQL
