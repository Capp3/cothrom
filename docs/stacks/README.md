# Stack Overview

Cothrom is organized into modular "stacks" - groups of related services that work together. Each stack is defined in a separate YAML file in the `docker/` directory and included into the root `compose.yml`.

## Stack Architecture

Each stack typically includes:

- **Application container(s)** - The primary service
- **Database** - PostgreSQL, MySQL/MariaDB, or MongoDB
- **Support services** - Redis, workers, cron jobs as needed
- **Volumes** - For persistent data and configuration
- **Networks** - Connected to appropriate Docker networks

## Include Structure

The root `compose.yml` includes stacks using the `include` directive:

```yaml
include:
  - path: ./docker/accounts.yml
  - path: ./docker/apps.yml
  - path: ./docker/cal.yml
  # ...
```

## Active vs Planned Stacks

### Active Stacks

These stacks are currently uncommented in `compose.yml` and deployed:

- See [Active Stacks](active.md) for details on each service

### Planned/Disabled Stacks

These stacks are commented out in `compose.yml`:

- See [Planned Stacks](planned.md) for future services

## Enabling/Disabling Stacks

To enable a stack, uncomment its line in `compose.yml`:

```yaml
include:
  - path: ./docker/office.yml  # Now enabled
```

To disable a stack, comment it out:

```yaml
include:
  # - path: ./docker/office.yml  # Now disabled
```

After making changes:

```bash
docker compose down
docker compose up -d
```

## Stack Dependencies

Some stacks depend on shared resources:

### Datastorage Stack

The `data.yml` stack includes `datastorage.yml`, which provides shared PostgreSQL instances for NocoDB workspaces. This allows multiple isolated NocoDB databases to run efficiently.

### Shared Networks

All stacks share the same network definitions from root `compose.yml`:
- `ingress` - External access
- `frontend` - Web applications
- `backend` - Background workers
- `database` - Database services

## Creating New Stacks

To add a new service stack:

1. Create `docker/newservice.yml` following the [service template](../service_templates.md)
2. Add to `compose.yml` include section
3. Add environment variables to `.env`
4. Configure labels for backup and metadata
5. Update documentation in [active.md](active.md)

Example minimal stack:

```yaml
services:
  newservice_app:
    image: service/image:latest
    container_name: newservice_app
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
    volumes:
      - newservice_data:/data
      - ${BACKUP_DIR}/newservice:/backup
    ports:
      - ${NEWSERVICE_PORT}:8080
    networks:
      - frontend
    restart: unless-stopped
    labels:
      - io.cothrom.role="app"
      - io.cothrom.stack="newservice"
      - io.cothrom.data="true"
      - io.cothrom.backup.policy="weekly"

volumes:
  newservice_data:
```

## Stack Naming Convention

Stacks follow these naming patterns:

- **File name**: `docker/<stack-name>.yml` (lowercase, hyphens)
- **Container names**: `<stack>_<service>` (e.g., `files_projectsend`)
- **Volume names**: `<stack>_<purpose>` (e.g., `files_config`, `files_db`)
- **Environment variables**: `<STACK>_<VARIABLE>` (uppercase, underscores)

## Port Allocation

Ports are allocated by stack in `.env`:

| Stack | Port Variable | Default Port |
|-------|--------------|--------------|
| accounts | ACCOUNTS_PORT | 12100 |
| apps | APPS_PORT | 12101 |
| cal | CAL_PORT | 12103 |
| data | DATA_PORT | 12104 |
| files | FILES_PORT | 12105 |
| grammar | GRAMMAR_PORT | 12106 |
| home | HOME_PORT | 12108 |
| pdf | PDF_PORT | - |
| pi | PI_GLANCES_PORT | - |

## Stack Labels

Every container has metadata labels:

```yaml
labels:
  - io.cothrom.role="app"              # app, database, worker, proxy
  - io.cothrom.stack="files"           # Stack identifier
  - io.cothrom.data="true"             # Has persistent data
  - io.cothrom.data.class="config"     # database, files, config
  - io.cothrom.backup.policy="weekly"  # daily, weekly, monthly
```

See [Labels](../configuration/labels.md) for complete documentation.
