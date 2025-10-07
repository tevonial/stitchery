CREATE TYPE "channel_type" AS ENUM (
  'amazon',
  'ebay',
  'walmart',
  'etsy',
  'shopify',
  'woocommerce'
);

CREATE TYPE "accounting_type" AS ENUM (
  'qbo',
  'xero',
  'netsuite'
);

CREATE TYPE "transaction_type" AS ENUM (
  'sale',
  'refund',
  'payout',
  'fee',
  'donation'
);

CREATE TYPE "role_type" AS ENUM (
  'admin',
  'limited'
);

CREATE TABLE "users" (
  "id" integer PRIMARY KEY,
  "username" varchar(50) NOT NULL,
  "role" role_type NOT NULL,
  "salt" bytea NOT NULL,
  "hash" bytea NOT NULL,
  "created_at" timestamp NOT NULL
);

CREATE TABLE "channels" (
  "id" integer PRIMARY KEY,
  "user_id" integer NOT NULL,
  "type" channel_type NOT NULL,
  "name" text NOT NULL,
  "sync_enabled" bool,
  "status" text,
  "created_at" timestamp NOT NULL,
  "last_sync" timestamp
);

CREATE TABLE "accounting_connections" (
  "id" integer PRIMARY KEY,
  "user_id" integer NOT NULL,
  "type" accounting_type NOT NULL,
  "name" varchar(100) NOT NULL,
  "sync_enabled" bool,
  "created_at" timestamp NOT NULL,
  "last_sync" timestamp
);

CREATE TABLE "transactions" (
  "id" integer PRIMARY KEY,
  "user_id" integer NOT NULL,
  "channel_id" integer NOT NULL,
  "type" transaction_type NOT NULL,
  "description" text,
  "amount" numeric(10,2) NOT NULL,
  "date" timestamp NOT NULL,
  "last_sync" timestamp
);

ALTER TABLE "channels" ADD CONSTRAINT "user_channels" FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "accounting_connections" ADD CONSTRAINT "user_accounting_connections" FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "transactions" ADD CONSTRAINT "user_transactions" FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "transactions" ADD CONSTRAINT "channel_transactions" FOREIGN KEY ("channel_id") REFERENCES "channels" ("id");
