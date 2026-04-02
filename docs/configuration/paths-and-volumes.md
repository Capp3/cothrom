# Paths and Volumes

This document explains the volume and path resolution strategy used throughout the Cothrom project.

## Overview

Cothrom uses three types of storage:

1. **Named Docker Volumes** - Managed by Docker, for databases and application-internal state
2. **Bind Mounts (DATA_DIR)** - Host directories for application data
3. **Bind Mounts (BACKUP_DIR)** - Host directories for backups
4. **Bind Mounts (config/)** - Project configuration files

## Path Resolution Rules

### Docker Compose Include Behavior

**Critical Understanding**: When Docker Compose includes a file, relative paths in that file resolve relative to the **included file's directory**, not the project root.

Example:
```
Project structure:
  compose.yml          (project root)
  docker/
    home.yml           (included file)
  config/
    home/
      conf.yml
```

In `docker/home.yml`:
```yaml
volumes:
  - ../config/home/:/app/user-data/
```

Resolution: `docker/../config/home/` → `config/home/` ✓ Correct!

### Why This Matters

This behavior can be confusing because:
- Paths starting with `./` or `../` resolve from the **included file's location**
- Paths starting with `/` are absolute from the host filesystem root
- Environment variables like `${DATA_DIR}` are absolute paths, so they work from anywhere

## Volume Strategy

### 1. Named Volumes (Docker-Managed)

**Use for**: Database data, application internal state

**Pattern**: `<stack>_<purpose>`

**Examples**:
```yaml
volumes:
  files_config:           # ProjectSend config
  files_db:               # MariaDB database data
  cal_config:             # Baikal config
  cal_data:               # Baikal calendar/contact data
  cal_db:                 # PostgreSQL database
```

**Location**: Docker manages these in `/var/lib/docker/volumes/`

**Backup**: Use `docker cp` or database dump commands

**Advantages**:
- Docker manages lifecycle
- Portable across systems
- Automatic cleanup on volume remove
- Better performance on some systems

### 2. Bind Mounts - Data Directory

**Use for**: Application data that needs host access

**Pattern**: `${DATA_DIR}/<stack>/<purpose>`

**Examples**:
```yaml
volumes:
  - ${DATA_DIR}/files:/data                    # Uploaded files
  - ${DATA_DIR}/documents/exports:/exports     # Exported documents
  - ${DATA_DIR}/documents/backups:/backups     # Document backups
```

**Default Location**: `/home/server/.local/data/` (configurable in `.env`)

**Directory Structure**:
```
${DATA_DIR}/
├── files/              # ProjectSend uploaded files
├── documents/
│   ├── exports/        # Etherpad exports
│   └── backups/        # Etherpad backups
└── apps_appsmith/      # Appsmith data (if enabled)
```

**Advantages**:
- Direct host access to files
- Easy to backup with host tools
- Can be on different filesystem/mount
- Visible to host applications

### 3. Bind Mounts - Backup Directory

**Use for**: Backup storage accessible from containers and host

**Pattern**: `${BACKUP_DIR}/<stack>`

**Examples**:
```yaml
volumes:
  - ${BACKUP_DIR}/files:/backup
  - ${BACKUP_DIR}/data/nocodb:/backup
  - ${BACKUP_DIR}/crm/server:/backup
```

**Default Location**: `/home/server/.local/backups/` (configurable in `.env`)

**Directory Structure**:
```
${BACKUP_DIR}/
├── accounts/           # Akaunting backups
├── cal/                # Baikal backups
├── crm/
│   └── server/         # Twenty CRM backups
├── data/
│   └── nocodb/         # NocoDB backups
├── files/              # ProjectSend backups
├── grammar/            # LanguageTool backups
├── grist/              # Grist backups (if enabled)
├── office/             # Collabora backups (if enabled)
└── project/            # OpenProject backups (if enabled)
```

**Usage**: Containers can write backups, host scripts can archive/transfer them

### 4. Bind Mounts - Config Directory

**Use for**: Editable configuration files that are version-controlled

**Pattern**: `../config/<stack>` (from `docker/` directory)

**Examples**:
```yaml
# From docker/home.yml
volumes:
  - ../config/home/:/app/user-data/

# From docker/pi.yml
volumes:
  - ../config/pi_home:/app/config
  - ../config/pi_assets:/app/assets
```

**Location**: `/home/server/code/cothrom/config/`

**Directory Structure**:
```
config/
├── home/                  # Dashy configuration
│   ├── conf.yml          # Main config
│   ├── README.md         # Config documentation
│   └── dashy-conf.schema.json
├── pi_home/              # Glance configuration
│   ├── glance.yml        # Main config
│   └── home.yml          # Alternative config
└── pi_assets/            # Glance custom assets
```

**Advantages**:
- Version controlled with Git
- Easy to edit with host editors
- Share between environments
- Documentation lives with config

## Complete Volume Type Reference

| Stack | Named Volumes | DATA_DIR Mounts | BACKUP_DIR Mounts | config/ Mounts |
|-------|---------------|-----------------|-------------------|----------------|
| accounts | `accounts_akaunting_data`<br>`accounts_akaunting_db` | - | `${BACKUP_DIR}/accounts` | - |
| apps | `apps_budibase_*`<br>`apps_couch_*`<br>`apps_minio_*` | Optional `${DATA_DIR}/apps_appsmith` | Optional `${BACKUP_DIR}/appsmith` | - |
| cal | `cal_config`<br>`cal_data`<br>`cal_db` | - | `${BACKUP_DIR}/cal` | - |
| crm | `crm-server-local-data`<br>`crm_db`<br>`crm_redis` | - | `${BACKUP_DIR}/crm/server` | - |
| data | `data_nocodb`<br>`data_nocodb_db`<br>`data_pgadmin`<br>+ datastorage volumes | - | `${BACKUP_DIR}/data/nocodb` | - |
| documents | `documents_postgres_data`<br>`documents_plugins`<br>`documents_etherpad-var` | `${DATA_DIR}/documents/exports`<br>`${DATA_DIR}/documents/backups` | - | `./build/documents/etherpad.settings.json` |
| draw | `draw_excalidraw` | - | - | - |
| files | `files_config`<br>`files_db` | `${DATA_DIR}/files` | `${BACKUP_DIR}/files` | - |
| grammar | `grammar_languagetool_ngrams` | - | `${BACKUP_DIR}/grammar` | - |
| home | `dashy_data` | - | - | `../config/home/` |
| pdf | `pdf_stirling-pdf` | - | - | - |
| pi | - | - | - | `../config/pi_home`<br>`../config/pi_assets` |

## Environment Variable Configuration

In `.env`:

```bash
# Data directory - application data accessible from host
DATA_DIR=/home/server/.local/data

# Backup directory - backup storage
BACKUP_DIR=/home/server/.local/backups
```

**Requirements**:
- Must be absolute paths
- Directories must exist before starting containers
- Must have appropriate permissions (typically 775)

**Setup**:
```bash
# Create directories
mkdir -p ${DATA_DIR}
mkdir -p ${BACKUP_DIR}

# Set permissions
chmod 775 ${DATA_DIR}
chmod 775 ${BACKUP_DIR}

# Optional: Set ownership
chown -R $USER:$USER ${DATA_DIR}
chown -R $USER:$USER ${BACKUP_DIR}
```

## Path Resolution Examples

### Example 1: Home Stack (config bind mount)

**File**: `docker/home.yml`

```yaml
services:
  dashy:
    volumes:
      - ../config/home/:/app/user-data/
```

**Resolution**:
1. Include file location: `docker/home.yml`
2. Relative path: `../config/home/`
3. Resolves to: `docker/../config/home/` = `config/home/`
4. Final host path: `/home/server/code/cothrom/config/home/`

### Example 2: Files Stack (DATA_DIR bind mount)

**File**: `docker/files.yml`

```yaml
services:
  files_projectsend:
    volumes:
      - ${DATA_DIR}/files:/data
```

**Resolution**:
1. Environment variable: `DATA_DIR=/home/server/.local/data`
2. Expands to: `/home/server/.local/data/files`
3. Mounts to container path: `/data`

### Example 3: Documents Stack (build context)

**File**: `docker/documents.yml`

```yaml
services:
  documents-etherpad:
    build:
      context: .
      dockerfile: build/dockerfile.etherpad
    volumes:
      - ./build/documents/etherpad.settings.json:/opt/etherpad-lite/settings.json
```

**Resolution**:
1. Build context `.` from `docker/documents.yml` = `docker/` directory
2. Dockerfile path: `build/dockerfile.etherpad` relative to context = `docker/build/dockerfile.etherpad`
3. Volume path: `./build/documents/...` from `docker/` = `docker/build/documents/etherpad.settings.json`

## Best Practices

### DO:
- ✓ Use named volumes for databases
- ✓ Use `${DATA_DIR}` for application data
- ✓ Use `${BACKUP_DIR}` for backups
- ✓ Use `../config/` for version-controlled configs
- ✓ Create host directories before starting containers
- ✓ Set appropriate permissions (775 or 755)
- ✓ Use absolute paths in `.env`

### DON'T:
- ✗ Mix named volumes and bind mounts for the same data
- ✗ Use relative paths in `.env` variables
- ✗ Store secrets in `config/` (use `.env` instead)
- ✗ Commit `.env` to version control
- ✗ Use root-owned directories without proper permissions

## Troubleshooting

### Permission Denied Errors

**Problem**: Container can't write to bind mount

**Solution**:
```bash
# Check ownership
ls -la ${DATA_DIR}

# Fix ownership
sudo chown -R $(id -u):$(id -g) ${DATA_DIR}
sudo chown -R $(id -u):$(id -g) ${BACKUP_DIR}

# Set PUID/PGID in .env
echo "PUID=$(id -u)" >> .env
echo "PGID=$(id -g)" >> .env
```

### Path Not Found

**Problem**: Container can't find mounted path

**Solution**:
1. Ensure directory exists: `mkdir -p ${DATA_DIR}/stackname`
2. Check `.env` for absolute paths
3. Verify path from included file's perspective
4. Check docker compose config: `docker compose config`

### Volume Shows as ./config in Project

**Problem**: IDE shows `./config` or `../config` paths in project tree

**Explanation**: This is expected behavior! These are bind mounts that make project directories accessible to containers. It's not a problem - it's intentional so you can edit configs from your host.

## Migration and Backup

### Backing Up Named Volumes

```bash
# Backup a named volume
docker run --rm \
  -v files_config:/source:ro \
  -v ${BACKUP_DIR}/files:/backup \
  alpine tar czf /backup/files_config.tar.gz -C /source .
```

### Moving Data Between Directories

```bash
# Stop containers
docker compose stop

# Move data
sudo mv ${DATA_DIR}/old_location ${DATA_DIR}/new_location

# Update .env if needed
nano .env

# Start containers
docker compose up -d
```

### Restoring from Backup

```bash
# Stop container
docker compose stop stackname_service

# Restore data
sudo tar xzf ${BACKUP_DIR}/stackname/backup.tar.gz -C ${DATA_DIR}/stackname/

# Fix permissions
sudo chown -R $(id -u):$(id -g) ${DATA_DIR}/stackname

# Start container
docker compose up -d stackname_service
```
