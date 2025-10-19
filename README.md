# Streamly-Docker — Environnement local

Ce dépôt sert **exclusivement** à lancer en local l’environnement Docker requis par l’application **Streamly** (hébergée dans un autre dépôt). Il fournit une base **PostgreSQL 16** et **Adminer** (UI web) pour gérer la base.

> ⚠️ Les identifiants/ports par défaut sont pensés pour le **développement local** uniquement.

---

## Prérequis

* **Docker** & **Docker Compose**

---

## Démarrage express

```bash
# 1) Cloner puis entrer dans le repo
git clone https://github.com/Streamly-project/Streamly-Docker.git
cd Streamly-Docker

# 2) Lancer les conteneurs
docker compose up -d

# 3) Vérifier
docker compose ps
```

* **Postgres** écoute sur `localhost:5432`
* **Adminer** est accessible sur `http://localhost:8080`

**Connexion Adminer** :

* Système : `PostgreSQL`
* Serveur : `postgres` (depuis le réseau Docker) **ou** `localhost`
* Utilisateur : `postgres`
* Mot de passe : `postgres`
* Base : `streamly`

---

## Utilisation côté application (repo Streamly)

L’application **Streamly** utilise **Prisma** et ton dossier `prisma/` existe déjà.

1. (Si besoin) Installer les deps Prisma :

```bash
npm i -D prisma
npm i @prisma/client
```

2. Configurer l’URL de la base dans le `.env` de l’app :

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/streamly?schema=public"
```

> Adapte le port si tu as modifié le mapping dans `docker-compose.yml`.

3. Générer le client Prisma :

```bash
npx prisma generate
```

4. Appliquer le schéma :

* Si tu as déjà des migrations :

  ```bash
  npx prisma migrate dev --name init
  ```
* Sinon, pousser le schéma directement :

  ```bash
  npx prisma db push
  ```

5. (Optionnel) Ouvrir Prisma Studio :

```bash
npx prisma studio
```

6. Démarrer l’application :

```bash
npm run dev
```

---

## Commandes utiles

```bash
# Voir l’état des conteneurs
docker compose ps

# Logs en direct (Postgres)
docker compose logs -f postgres

# Ouvrir un shell psql dans le conteneur Postgres
docker exec -it $(docker ps -qf name=postgres) psql -U postgres -d streamly

# Arrêter la stack
docker compose down

# Réinitialiser complètement (⚠️ efface la base locale)
docker compose down -v
```