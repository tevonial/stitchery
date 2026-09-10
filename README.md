# Stitchery

**Stitchery** is an integration and data synchronization platform designed to unify e-commerce channels (Amazon, eBay, Walmart, Etsy, Shopify, WooCommerce), accounting platforms (QuickBooks Online, Xero, NetSuite), and custom data sources into a single ecosystem.

This repository serves as the **parent container and orchestrator** that ties together the multi-service architecture using Git submodules and Docker Compose.

---

## 🏗️ System Architecture

```
                                  +-------------------+
                                  |   Client Browser  |
                                  +---------+---------+
                                            |
                                            v
                                  +-------------------+
                                  |    Nginx Proxy    |
                                  +----+---------+----+
                                       |         |
                      +----------------+         +----------------+
                      | (Port 8080)                               | (Ports 3000 / 3001)
                      v                                           v
       +----------------------------+              +----------------------------+
       |     stitchery-frontend     |              |       stitchery-api        |
       |  (Angular 21 + SSR Node)   |              |  (Apollo GraphQL / REST)   |
       +----------------------------+              +----+------------------+----+
                                                        |                  |
                                                        v                  v
                                               +------------------+  +--------------+
                                               |   stitchery-db   |  |    Redis     |
                                               |   (PostgreSQL)   |  |   (BullMQ)   |
                                               +------------------+  +--------------+
```

### Core Services & Submodules

- **`stitchery-frontend`** _(Git Submodule)_: Angular 21 Server-Side Rendered (SSR) web application with Angular Material, dynamic form rendering, and Apollo Angular GraphQL integration.
- **`stitchery-api`** _(Git Submodule)_: Node.js (ESM) backend exposing Apollo GraphQL (`/graphql`) and Express REST OAuth/Connect endpoints (`/connect`, `/auth`), using Nexus for GraphQL schema composition, Prisma 7 for PostgreSQL access, and BullMQ/Redis for background job queues.
- **`stitchery-db`**: PostgreSQL database service pre-configured with core system schemas and initialization scripts (`stitchery-db-init.sql`).
- **`nginx`**: Reverse proxy and SSL termination layer managing subdomains/routes between API and Frontend services.
- **`redis`**: In-memory data store supporting BullMQ job queues and caching.
- **`pg-admin`**: Web interface for managing the PostgreSQL instance.
- **`certbot`**: Automated Let's Encrypt certificate renewal daemon.
- **`dev-tunnel`**: Cloudflare tunnel integration for exposing local environments securely.

---

## 📁 Repository Structure

```
.
├── config/                      # Infrastructure & integration configurations
│   ├── certbot/                 # SSL certificate renewal hooks & storage
│   ├── connect/                 # Integration specs, OAuth flows, and OpenAPI definitions
│   │   ├── auth/                # Third-party OAuth configurations (Amazon, eBay, Google)
│   │   ├── openapi/             # OpenAPI schemas (Amazon, eBay, Google Sheets)
│   │   └── test-flows/          # Automated flow definitions
│   ├── nginx/                   # Nginx templates and auto-reload scripts
│   ├── pgadmin4/                # PgAdmin server and layout definitions
│   └── secrets/                 # Local credentials and secret files (git-ignored)
├── stitchery-api/               # [Submodule] Backend API & Connect engine
├── stitchery-db/                # PostgreSQL container & initialization scripts
├── stitchery-frontend/          # [Submodule] Angular 21 SSR frontend application
├── docker-compose.yml           # Primary Docker stack definition
├── docker-compose.debug.yml     # Debugging overlays
└── README.md                    # Parent repository overview
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed locally:

- [Git](https://git-scm.com/) (v2.30+)
- [Docker](https://www.docker.com/) & [Docker Compose](https://docs.docker.com/compose/) (v2.0+)
- [Node.js](https://nodejs.org/) (v22+ recommended for local dev)

### 1. Cloning the Repository

Because this repository uses Git submodules, clone recursively to pull both child repositories:

```bash
git clone --recursive https://github.com/tevonial/stitchery.git
cd stitchery
```

If you already cloned without `--recursive`, initialize submodules manually:

```bash
git submodule update --init --recursive
```

### 2. Secrets & Environment Setup

Copy template files in `config/secrets/` to set up local credentials:

```bash
cp config/secrets/db-credentials.template config/secrets/db-credentials
cp config/secrets/jwt-secret.template config/secrets/jwt-secret
# Populate values inside db-credentials, jwt-secret, connect-secret, and pg-admin-password
```

Create a root `.env` file or export environment variables for ports and domain settings:

```env
APP_DOMAIN=localhost
FRONTEND_PORT=8080
API_PORT_GRAPHQL=3000
API_PORT_REST=3001
CONFIG_DIR=./config
SECRETS_DIR=./config/secrets/
ASSETS_DIR=./assets
DB_CREDENTIALS_FILE=db-credentials
JWT_SECRET_FILE=jwt-secret
CONNECT_SECRET_FILE=connect-secret
```

### 3. Running with Docker Compose

To start the entire stack:

```bash
docker compose up --build
```

Access the services:

- **Frontend Web App**: `http://localhost:8080` (or configured `FRONTEND_PORT`)
- **GraphQL Endpoint**: `http://localhost:3000/graphql`
- **REST / OAuth Endpoints**: `http://localhost:3001`
- **PgAdmin**: `http://localhost:5050` (or mapped port)

To run a single service (e.g. backend API only):

```bash
docker compose up --build api
```

---

## 🛠️ Submodules

Each submodule maintains its own development scripts and configuration. Refer to the submodule documentation for standalone local development without Docker:

- [**`stitchery-api` Documentation**](./stitchery-api/README.md) - API endpoints, GraphQL Nexus schema generation, Prisma migrations, and Connect flow runner.
- [**`stitchery-frontend` Documentation**](./stitchery-frontend/README.md) - Angular CLI commands, SSR build pipeline, Type Bundler integration, and testing.

---

## 📜 License

UNLICENSED — Internal / Proprietary.
