# Streamly-Docker — Local Environment

This repo spins up a **PostgreSQL 16** database for the **Streamly** app (app code lives in a separate repository).

---

## Prerequisites

* **Docker** & **Docker Compose**

---

## What’s inside

* `docker-compose.yml` → Postgres + a one-shot **init-seed** service
* `sql/init.sql` → your SQL script executed once at startup (you can comment out the service later)

---

## Quick Start

```bash
# From this repository
docker compose up -d

# Check status
docker compose ps
```

When Postgres shows **healthy**, apply your app schema from the **Streamly** app repo:

```bash
cd ../Streamly                    # go to the app repo (adjust path)
# Apply existing migrations (recommended)
npx prisma migrate deploy
# If you have no migrations yet (dev only):
# npx prisma db push
npx prisma generate
```

**Seed script** (runs once): the `init-seed` service executes `./sql/init.sql` after Postgres is ready to accept connections. To run it again later:

```bash
cd ../Streamly-Docker
# re-run the one-shot job only
docker compose up --force-recreate --no-deps init-seed
# see logs
docker compose logs init-seed
```

To **disable** seeding, comment the `init-seed` service in `docker-compose.yml` and `docker compose up -d` again.

---

## Configuration

* Postgres listens on **`localhost:5432`**
* Default credentials: `postgres / postgres`
* Default DB: `streamly`

In your **Streamly app** `.env`:

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/streamly?schema=public"
```

> If you change ports or credentials in `docker-compose.yml`, reflect that here.

**Healthcheck?** It waits until the database actually **accepts connections** before dependent services (like the seed job) run. It does **not** apply migrations for you. Do that from the app repo as shown above.

---

## Seeding

Place idempotent SQL in `./sql/init.sql`, e.g.:

```sql
-- Create admin only if missing
INSERT INTO "User" (username, password, role)
SELECT 'admin', 'admin', 'ADMIN'::"Role"
WHERE NOT EXISTS (SELECT 1 FROM "User" WHERE username = 'admin');
```

---

## Simple Backup / Restore

**Export** the whole DB to a plain SQL file (run from this repo; writes to `./backups/` — make sure the folder exists):

```bash
docker exec -e PGPASSWORD=postgres streamly-db pg_dump -U postgres -d streamly > ./backups/streamly_$(date +%F_%H%M).sql
```

**Restore**:

```bash
docker exec -e PGPASSWORD=postgres -i streamly-db psql -U postgres -d streamly < ./backups/streamly_xxxx-xx-xx_xxxx.sql```

---

## Useful Commands

```bash
# Status
docker compose ps

# Live logs (Postgres)
docker compose logs -f postgres

# psql shell inside the container
docker exec -it streamly-db psql -U postgres -d streamly

# Stop stack
docker compose down

# Reset EVERYTHING (⚠️ deletes the local database volume)
docker compose down -v

# Remove stray/old containers attached to this project
docker compose down --remove-orphans
```

---

## Troubleshooting

* **`The table "public.User" does not exist`** in Prisma Studio → You wiped the volume or never applied the schema. From the app repo:

  ```bash
  npx prisma migrate deploy   # or: npx prisma db push
  npx prisma generate
  ```
* **Seed didn’t run** → check `docker compose logs init-seed`. The seed runs **after** Postgres is healthy, but **before** your Prisma migrations unless you apply them — make sure tables exist first.
* **Can’t connect from app** → confirm `.env` `DATABASE_URL` points to `localhost:5432` with correct creds.