# Streamly-Docker — Local Environment

This repository is **exclusively** used to run the Docker environment required by the **Streamly** application (hosted in a separate repository) locally. It provides a **PostgreSQL 16** database and **Adminer** (web UI) to manage the database.

> ⚠️ Default credentials/ports are intended for **local development** only.

---

## Prerequisites

* **Docker** & **Docker Compose**

---

## Quick Start

```bash
# 1) Clone and enter the repository
git clone https://github.com/Streamly-project/Streamly-Docker.git
cd Streamly-Docker

# 2) Start the containers
docker compose up -d

# 3) Verify
docker compose ps
```

* **Postgres** listens on `localhost:5432`
* **Adminer** is accessible at `http://localhost:8080`

**Adminer Connection** :

* System: `PostgreSQL`
* Server: `postgres` (from Docker network) **or** `localhost`
* Username: `postgres`
* Password: `postgres`
* Database: `streamly`

---

## Application Usage (Streamly Repository)

The **Streamly** application uses **Prisma** and your `prisma/` folder already exists.

1. (If needed) Install Prisma dependencies:

```bash
npm i -D prisma
npm i @prisma/client
```

2. Configure the database URL in the application's `.env`:

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/streamly?schema=public"
```

> Adjust the port if you have modified the mapping in `docker-compose.yml`.

3. Generate the Prisma client:

```bash
npx prisma generate
```

4. Apply the schema:

* If you already have migrations:

  ```bash
  npx prisma migrate dev --name init
  ```
* Otherwise, push the schema directly:

  ```bash
  npx prisma db push
  ```

5. (Optional) Open Prisma Studio:

```bash
npx prisma studio
```

6. Start the application:

```bash
npm run dev
```

---

## Useful Commands

```bash
# View container status
docker compose ps

# Live logs (Postgres)
docker compose logs -f postgres

# Open a psql shell in the Postgres container
docker exec -it $(docker ps -qf name=postgres) psql -U postgres -d streamly

# Stop the stack
docker compose down

# Completely reset (⚠️ deletes local database)
docker compose down -v
```
