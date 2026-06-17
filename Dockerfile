FROM postgres:14.23-trixie

COPY sql/01_schema.sql /docker-entrypoint-initdb.d/01_schema.sql
COPY sql/02_triggers.sql /docker-entrypoint-initdb.d/02_triggers.sql
COPY sql/03_indexes.sql /docker-entrypoint-initdb.d/03_indexes.sql