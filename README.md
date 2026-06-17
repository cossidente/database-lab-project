# database-lab-project

![Status](https://img.shields.io/badge/status-WIP-orange.svg)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=flat&logo=docker&logoColor=white)
![uv](https://img.shields.io/badge/uv-Astral-5A67D8?logo=uv&logoColor=white)

Database Lab project for the Database Systems course at the University of Udine (UniUD), A.Y. 2025/2026.

______________________________________________________________________

## 📂 Project Structure

| Path | Description |
|------|-------------|
| `report/` | Official project report (written in Italian) |
| `schemas/` | Entity-Relationship (ER) and logical diagrams |
| `data/` | Static data used for populating the database |
| `src/` | Source code used for interacting with the database |
| `sql/01_schema.sql` | Table definitions and constraints |
| `sql/02_triggers.sql` | Triggers and trigger functions |
| `sql/03_indexes.sql` | Index definitions |
| `sql/04_queries.sql` | Queries for testing and demonstration purposes |
| `src/populate.py` | Generates and inserts random but coherent data into the database |
| `src/redundancy_analysis.py` | Reproduces the redundancy cost analysis and scalability study presented in the report |
| `Dockerfile` | PostgreSQL image definition |
| `docker-compose.yml` | Container configuration |
| `.env` | File with environment variables, included to reproduce the database easily |

______________________________________________________________________

## 🐳 Getting Started with Docker

### Prerequisites

The project depends on [Docker](https://docs.docker.com/get-docker/) (including [Docker Compose](https://docs.docker.com/compose/install/)) for database deployment and on [uv](https://docs.astral.sh/uv/) for Python dependency management and script execution. Make sure these tools are installed before proceeding with the setup.

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
uv run src/populate.py
```

This will populate every table of the database with random but coherent data.

**4. Stop the container:**

```bash
docker compose down
```

______________________________________________________________________

## 📈 Redundancy Analysis

The repository also includes a utility script used to reproduce the redundancy analysis discussed in the report.

```bash
uv run src/redundancy_analysis.py
```

The script reproduces the quantitative evaluation presented in the report by computing the annual cost of the two alternative strategies (with and without redundancy), determining their break-even point, and generating a scalability plot that shows how the total number of database accesses evolves as the yearly number of exam registrations increases. The resulting figure also highlights both the estimated operational workload of the system and the threshold beyond which the redundant solution would no longer be advantageous.

This script is provided for reproducibility purposes and to support the quantitative evaluation presented in the report.

______________________________________________________________________

## Database Credentials

| Property | Value |
|----------|-------|
| **Host** | `localhost` |
| **Port** | `5432` |
| **Username** | `admin` |
| **Password** | `password` |
| **Database** | `21-database-lab-project` |

______________________________________________________________________

### ⚠️ No Persistent Storage

Stopping the container with `docker compose down` **wipes all data**. The database is re-initialized from the `sql/` scripts on the next `docker compose up`. To persist data between restarts, configure a Docker volume in `docker-compose.yml`.

### Rebuilding the Container

After changes to `Dockerfile`, `docker-compose.yml`, or any SQL script, run:

```bash
docker compose down
docker compose up --build
```
