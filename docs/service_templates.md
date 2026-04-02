# Service Templates

This document provides templates for adding new services to the Cothrom stack.

## Before You Start

1. Choose a stack name (lowercase, hyphenated: `my-service`)
2. Add environment variables to `.env`
3. Decide on networks needed (frontend, backend, database)
4. Plan volume strategy (see [Paths and Volumes](configuration/paths-and-volumes.md))

## Basic Service Template

Minimal single-container service:

```yaml
services:
  stackname_app:
    image: organization/image:latest
    container_name: stackname_app
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
    volumes:
      - stackname_data:/data
      - ${BACKUP_DIR}/stackname:/backup
    ports:
      - ${STACKNAME_PORT}:8080
    networks:
      - frontend
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    labels:
      - io.cothrom.role="app"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="true"
      - io.cothrom.data.class="config"
      - io.cothrom.backup.policy="weekly"

volumes:
  stackname_data:
```

## Service + Database Template

Application with database:

```yaml
services:
  stackname_app:
    image: organization/app:latest
    container_name: stackname_app
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - DB_HOST=stackname_db
      - DB_PORT=5432
      - DB_NAME=stackname
      - DB_USER=stackname
      - DB_PASSWORD=${STACKNAME_DB_PASSWORD}
    volumes:
      - stackname_data:/data
      - ${DATA_DIR}/stackname:/files
      - ${BACKUP_DIR}/stackname:/backup
    ports:
      - ${STACKNAME_PORT}:8080
    networks:
      - frontend
      - database
    depends_on:
      stackname_db:
        condition: service_healthy
    restart: unless-stopped
    labels:
      - io.cothrom.role="app"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="true"
      - io.cothrom.data.class="config"
      - io.cothrom.backup.policy="weekly"

  stackname_db:
    image: postgres:17-bookworm
    container_name: stackname_db
    environment:
      POSTGRES_DB: stackname
      POSTGRES_USER: stackname
      POSTGRES_PASSWORD: ${STACKNAME_DB_PASSWORD}
    volumes:
      - stackname_db:/var/lib/postgresql/data
    networks:
      - database
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U stackname -d stackname"]
      interval: 10s
      timeout: 2s
      retries: 10
    labels:
      - io.cothrom.role="database"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="true"
      - io.cothrom.data.class="database"
      - io.cothrom.db.engine="postgres"
      - io.cothrom.db.backup.command="pg_dump -U $$POSTGRES_USER -d $$POSTGRES_DB"
      - io.cothrom.backup.policy="weekly"

volumes:
  stackname_data:
  stackname_db:
```

## Database-Only Templates

### PostgreSQL

```yaml
services:
  stackname_db:
    image: postgres:17-bookworm
    container_name: stackname_db
    environment:
      POSTGRES_DB: stackname
      POSTGRES_USER: stackname
      POSTGRES_PASSWORD: ${STACKNAME_POSTGRES_PASSWORD}
      PGDATA: /var/lib/postgresql/data/pgdata
    volumes:
      - stackname_db:/var/lib/postgresql/data
    networks:
      - database
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB"]
      interval: 10s
      timeout: 2s
      retries: 10
    labels:
      - io.cothrom.role="database"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="true"
      - io.cothrom.data.class="database"
      - io.cothrom.db.engine="postgres"
      - io.cothrom.db.backup.command="pg_dump -U $$POSTGRES_USER -d $$POSTGRES_DB"
      - io.cothrom.backup.policy="weekly"

volumes:
  stackname_db:
```

### MySQL/MariaDB

```yaml
services:
  stackname_db:
    image: mariadb:noble
    container_name: stackname_db
    environment:
      MYSQL_DATABASE: stackname
      MYSQL_USER: stackname
      MYSQL_PASSWORD: ${STACKNAME_DB_PASSWORD}
      MYSQL_RANDOM_ROOT_PASSWORD: "yes"
    volumes:
      - stackname_db:/var/lib/mysql
    networks:
      - database
    restart: always
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 10
    labels:
      - io.cothrom.role="database"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="true"
      - io.cothrom.data.class="database"
      - io.cothrom.db.engine="mariadb"
      - io.cothrom.db.backup.command="mysqldump -u $$MYSQL_USER -p$$MYSQL_PASSWORD $$MYSQL_DATABASE"
      - io.cothrom.backup.policy="weekly"

volumes:
  stackname_db:
```

### MongoDB

```yaml
services:
  stackname_db:
    image: mongo:7
    container_name: stackname_db
    environment:
      MONGO_INITDB_ROOT_USERNAME: stackname
      MONGO_INITDB_ROOT_PASSWORD: ${STACKNAME_MONGO_PASSWORD}
      MONGO_INITDB_DATABASE: stackname
    volumes:
      - stackname_db:/data/db
    networks:
      - database
    restart: always
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')"]
      interval: 10s
      timeout: 5s
      retries: 10
    labels:
      - io.cothrom.role="database"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="true"
      - io.cothrom.data.class="database"
      - io.cothrom.db.engine="mongodb"
      - io.cothrom.db.backup.command="mongodump --uri=mongodb://$$MONGO_INITDB_ROOT_USERNAME:$$MONGO_INITDB_ROOT_PASSWORD@localhost:27017/$$MONGO_INITDB_DATABASE"
      - io.cothrom.backup.policy="weekly"

volumes:
  stackname_db:
```

### Redis Cache

```yaml
services:
  stackname_redis:
    image: redis:7-alpine
    container_name: stackname_redis
    command: redis-server --appendonly yes
    volumes:
      - stackname_redis:/data
    networks:
      - database
    restart: always
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 10
    labels:
      - io.cothrom.role="cache"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="true"
      - io.cothrom.data.class="database"
      - io.cothrom.db.engine="redis"
      - io.cothrom.backup.policy="weekly"

volumes:
  stackname_redis:
```

## Advanced Pattern: App + Worker + Database

Multi-container stack with background workers:

```yaml
services:
  stackname_web:
    image: organization/app:latest
    container_name: stackname_web
    environment:
      - DATABASE_URL=postgres://stackname:${STACKNAME_DB_PASSWORD}@stackname_db:5432/stackname
      - REDIS_URL=redis://stackname_redis:6379
    volumes:
      - stackname_data:/data
      - ${BACKUP_DIR}/stackname:/backup
    ports:
      - ${STACKNAME_PORT}:8080
    networks:
      - frontend
      - backend
      - database
    depends_on:
      stackname_db:
        condition: service_healthy
      stackname_redis:
        condition: service_healthy
    restart: unless-stopped
    labels:
      - io.cothrom.role="app"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="true"
      - io.cothrom.data.class="config"
      - io.cothrom.backup.policy="weekly"

  stackname_worker:
    image: organization/app:latest
    container_name: stackname_worker
    command: worker
    environment:
      - DATABASE_URL=postgres://stackname:${STACKNAME_DB_PASSWORD}@stackname_db:5432/stackname
      - REDIS_URL=redis://stackname_redis:6379
    networks:
      - backend
      - database
    depends_on:
      stackname_db:
        condition: service_healthy
      stackname_redis:
        condition: service_healthy
    restart: unless-stopped
    labels:
      - io.cothrom.role="worker"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="false"

  stackname_db:
    image: postgres:17-bookworm
    container_name: stackname_db
    environment:
      POSTGRES_DB: stackname
      POSTGRES_USER: stackname
      POSTGRES_PASSWORD: ${STACKNAME_DB_PASSWORD}
    volumes:
      - stackname_db:/var/lib/postgresql/data
    networks:
      - database
    restart: always
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U stackname"]
      interval: 10s
      timeout: 2s
      retries: 10
    labels:
      - io.cothrom.role="database"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="true"
      - io.cothrom.data.class="database"
      - io.cothrom.db.engine="postgres"
      - io.cothrom.db.backup.command="pg_dump -U $$POSTGRES_USER -d $$POSTGRES_DB"
      - io.cothrom.backup.policy="daily"

  stackname_redis:
    image: redis:7-alpine
    container_name: stackname_redis
    networks:
      - database
    restart: always
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 10
    labels:
      - io.cothrom.role="cache"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="false"

volumes:
  stackname_data:
  stackname_db:
```

## Using YAML Anchors

For consistency, you can use the shared anchors from root `compose.yml`:

```yaml
services:
  stackname_db:
    <<: [*post_health_policy, *db_restart_policy, *post-image, *db-network]
    container_name: stackname_db
    environment:
      POSTGRES_DB: stackname
      POSTGRES_PASSWORD: ${STACKNAME_POSTGRES_PASSWORD}
      POSTGRES_USER: stackname
    volumes:
      - stackname_db:/var/lib/postgresql/data
    labels:
      - io.cothrom.role="database"
      - io.cothrom.stack="stackname"
      - io.cothrom.data="true"
      - io.cothrom.data.class="database"
      - io.cothrom.db.engine="postgres"
      - io.cothrom.db.backup.command="pg_dump -U $$POSTGRES_USER -d $$POSTGRES_DB"
      - io.cothrom.backup.policy="weekly"

volumes:
  stackname_db:
```

Available anchors from `compose.yml`:
- `*app_restart_policy` - `restart: unless-stopped`
- `*db_restart_policy` - `restart: always`
- `*post_health_policy` - PostgreSQL healthcheck
- `*post-image` - `image: postgres:17-bookworm`
- `*db-network` - `networks: [database]`
- `*app-network` - `networks: [database, frontend, backend]`

## Checklist for New Service

- [ ] Create `docker/stackname.yml`
- [ ] Add to `compose.yml` includes
- [ ] Add environment variables to `.env`:
  - `STACKNAME_PORT`
  - `STACKNAME_DB_PASSWORD` (if using database)
  - Service-specific vars
- [ ] Add labels to all containers:
  - `io.cothrom.role`
  - `io.cothrom.stack`
  - `io.cothrom.data`
  - `io.cothrom.backup.policy`
- [ ] Create data directories if using bind mounts:
  ```bash
  mkdir -p ${DATA_DIR}/stackname
  mkdir -p ${BACKUP_DIR}/stackname
  ```
- [ ] Test startup:
  ```bash
  docker compose up -d stackname_app
  docker compose logs -f stackname_app
  ```
- [ ] Document in `docs/stacks/active.md`
- [ ] Configure Cloudflare tunnel route (if needed)

## Best Practices

### DO:
- ✓ Use meaningful container names: `stackname_service`
- ✓ Include healthchecks for critical services
- ✓ Use `depends_on` with `condition: service_healthy`
- ✓ Label all containers properly
- ✓ Use environment variables for configuration
- ✓ Set appropriate restart policies
- ✓ Use named volumes for databases
- ✓ Document in [Active Stacks](stacks/active.md)

### DON'T:
- ✗ Hardcode passwords in compose files
- ✗ Use `latest` tag in production (use specific versions)
- ✗ Skip healthchecks on databases
- ✗ Mix different naming conventions
- ✗ Forget to add to `.gitignore` if creating custom configs
- ✗ Expose databases on public ports
- ✗ Skip backup labels

## Testing New Services

```bash
# Validate compose syntax
docker compose config --quiet

# Start in foreground to see errors
docker compose up stackname_app

# Check logs
docker compose logs stackname_app

# Test healthcheck
docker inspect --format='{{.State.Health.Status}}' stackname_app

# Verify networks
docker inspect stackname_app | jq '.[].NetworkSettings.Networks'

# Check labels
docker inspect --format='{{json .Config.Labels}}' stackname_app | jq
```
