FROM postgres:latest

ENV BACKUP_DIR = /tmp/backups
ENV READONLY_ROLE = readonly

COPY ./scripts /docker-entrypoint-initdb.d
COPY ./backup /
RUN mkdir -p /docker-entrypoint-initdb.d; mkdir -p ${BACKUP_DIR}; chmod +x /backup.sh
