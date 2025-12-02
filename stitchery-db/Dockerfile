# syntax=docker/dockerfile:1
FROM postgres:bookworm

WORKDIR /app

RUN mkdir -p /entrypoint.d
COPY db-entrypoint.sh .
RUN chmod +x db-entrypoint.sh

ENTRYPOINT [ "./db-entrypoint.sh" ]
CMD [ "postgres" ]