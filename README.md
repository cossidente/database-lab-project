# database-lab-project

![Status](https://img.shields.io/badge/status-WIP-orange.svg)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)

Database Lab project for the Database Systems course at the University of Udine (UniUD), A.Y. 2025/2026.

---

## 📂 Project Structure

| Path | Description |
|------|-------------|
| `report/` | Official project report (written in Italian) |
| `schemas/` | Entity-Relationship (ER) and logical diagrams |
| `sql/01_schema.sql` | Table definitions and constraints |
| `sql/02_triggers.sql` | Triggers and trigger functions |
| `sql/03_seed.sql` | Sample data |
| `Dockerfile` | PostgreSQL image definition |
| `docker-compose.yml` | Container configuration |

---

## 🐳 Getting Started with Docker

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Running the Database

**1. Build and start the PostgreSQL container:**
```bash
docker compose up -d
```

This will build the Docker image, start a PostgreSQL container, initialize the database from the scripts in `init/`, and expose it on `localhost:5432`.

**2. Stop the container:**
```bash
docker compose down
```

### Database Credentials

| Property | Value |
|----------|-------|
| **Host** | `localhost` |
| **Port** | `5432` |
| **Username** | `admin` |
| **Password** | `password` |
| **Database** | `21-database-lab-project` |

### ⚠️ No Persistent Storage

Stopping the container with `docker compose down` **wipes all data**. The database is re-initialized from the `init/` scripts on the next `docker compose up`. To persist data between restarts, configure a Docker volume in `docker-compose.yml`.

### Rebuilding the Container

After changes to `Dockerfile`, `docker-compose.yml`, or any SQL script, run:

```bash
docker compose down
docker compose up --build
```

---

## ⚠️ Repository Rules

Direct pushes to `main` are **not allowed**. All changes must go through a Pull Request.