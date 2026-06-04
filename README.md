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
| `data/` | Static data used for populating the database |
| `src/` | Source code used for interacting with the database |
| `sql/01_schema.sql` | Table definitions and constraints |
| `sql/02_triggers.sql` | Triggers and trigger functions |
| `src/main.py` | Random data generator for populating the database |
| `Dockerfile` | PostgreSQL image definition |
| `docker-compose.yml` | Container configuration |
| `.env` | File with environment variables, included to reproduce the database easily |

---

## 🐳 Getting Started with Docker

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [uv](https://docs.astral.sh/uv/)

### Quick Start

**1. Install Python dependencies:**
```bash
uv sync
```

This will create a virtual environment and install all project dependencies from `pyproject.toml`.

**2. Start the PostgreSQL container:**
```bash
docker compose up -d --build
```

This will build the Docker image, start a PostgreSQL container, and initialize the database from the scripts in `sql/`, exposing it on `localhost:5432`.

**3. Populate the database:**
```bash
uv run python src/main.py
```

This will populate every table of the database with random but coherent data.

**4. Stop the container:**
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

Stopping the container with `docker compose down` **wipes all data**. The database is re-initialized from the `sql/` scripts on the next `docker compose up`. To persist data between restarts, configure a Docker volume in `docker-compose.yml`.

### Rebuilding the Container

After changes to `Dockerfile`, `docker-compose.yml`, or any SQL script, run:

```bash
docker compose down
docker compose up --build
```

---

## ⚠️ Repository Rules

Direct pushes to `main` are **not allowed**. All changes must go through a Pull Request.