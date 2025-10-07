# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/devcontainers/typescript-node:22-bookworm
WORKDIR /workspace
RUN npm i --prefix ./stitchery-frontend install
RUN npm i --prefix ./stitchery-api install
CMD ["tail", "-f", "/dev/null"]