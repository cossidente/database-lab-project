FROM postgres:14.23-trixie

COPY sql/ /docker-entrypoint-initdb.d/