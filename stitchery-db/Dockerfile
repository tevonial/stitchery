# syntax=docker/dockerfile:1
FROM postgres:bookworm

WORKDIR /app
COPY stitchery-db-init.sql /docker-entrypoint-initdb.d

RUN mkdir -p /entrypoint.d
COPY db-entrypoint.sh .

ENTRYPOINT [ "./db-entrypoint.sh" ]
CMD [ "postgres" ]