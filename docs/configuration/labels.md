# Container Labels

Cothrom uses Docker labels to classify and document containers. Labels enable automation for backups, monitoring, and service discovery.

## Label Namespace

All Cothrom labels use the `io.cothrom.*` namespace to avoid conflicts with other systems.

## Label Reference

### io.cothrom.role

**Purpose**: Defines the container's role in the stack

**Required**: Yes (on all containers)

**Values**:
- `app` - Application/web server
- `database` - Database server
- `proxy` - Reverse proxy or gateway
- `worker` - Background worker process
- `cache` - Caching service (Redis, Memcached)
- `storage` - Object/file storage service

**Examples**:
```yaml
labels:
  - io.cothrom.role="app"        # Main application
  - io.cothrom.role="database"   # Database container
  - io.cothrom.role="worker"     # Background worker
```

---

### io.cothrom.stack

**Purpose**: Identifies which logical stack/service group the container belongs to

**Required**: Yes (on all containers)

**Format**: Lowercase stack name matching the compose file name

**Examples**:
```yaml
labels:
  - io.cothrom.stack="files"      # From docker/files.yml
  - io.cothrom.stack="data"       # From docker/data.yml
  - io.cothrom.stack="crm"        # From docker/crm.yml
```

**Stack Names**:
- `accounts` - Akaunting
- `apps` - Budibase
- `cal` - Baikal
- `company` - Dolibarr
- `crm` - Twenty CRM
- `data` - NocoDB
- `datastorage` - Shared PostgreSQL databases
- `documents` - Etherpad
- `draw` - Excalidraw
- `files` - ProjectSend
- `grammar` - LanguageTool
- `grist` - Grist
- `home` - Dashy
- `meetings` - OpenMeetings
- `office` - Collabora
- `pdf` - Stirling PDF
- `pi` - Glance
- `project` - OpenProject

---

### io.cothrom.data

**Purpose**: Indicates whether the container has persistent data that needs backup

**Required**: Yes (on all containers)

**Values**:
- `true` - Container has persistent data
- `false` - Stateless container, no backup needed

**Examples**:
```yaml
labels:
  - io.cothrom.data="true"   # Has data, needs backup
  - io.cothrom.data="false"  # Stateless
```

---

### io.cothrom.data.class

**Purpose**: Classifies the type of persistent data stored

**Required**: Only if `io.cothrom.data="true"`

**Values**:
- `database` - Database files (PostgreSQL, MySQL, etc.)
- `files` - User-uploaded files or documents
- `config` - Application configuration and settings

**Examples**:
```yaml
labels:
  - io.cothrom.data="true"
  - io.cothrom.data.class="database"    # Database data

labels:
  - io.cothrom.data="true"
  - io.cothrom.data.class="files"       # User files

labels:
  - io.cothrom.data="true"
  - io.cothrom.data.class="config"      # App config
```

---

### io.cothrom.db.engine

**Purpose**: Specifies the database engine type

**Required**: Only if `io.cothrom.role="database"`

**Values**:
- `postgres` - PostgreSQL
- `mysql` - MySQL
- `mariadb` - MariaDB
- `mongodb` - MongoDB
- `redis` - Redis
- `couchdb` - CouchDB
- `memcached` - Memcached

**Examples**:
```yaml
labels:
  - io.cothrom.role="database"
  - io.cothrom.db.engine="postgres"

labels:
  - io.cothrom.role="database"
  - io.cothrom.db.engine="mariadb"
```

---

### io.cothrom.db.backup.command

**Purpose**: Provides the command to backup this database

**Required**: Only if `io.cothrom.role="database"`

**Format**: Shell command with environment variable substitution

**Examples**:
```yaml
# PostgreSQL
labels:
  - io.cothrom.db.backup.command="pg_dump -U $POSTGRES_USER -d $POSTGRES_DB"

# MySQL/MariaDB
labels:
  - io.cothrom.db.backup.command="mysqldump -u $MYSQL_USER -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"

# MongoDB
labels:
  - io.cothrom.db.backup.command="mongodump --uri=$MONGO_URI"
```

**Usage in Backup Scripts**:
```bash
# Extract backup command from label
BACKUP_CMD=$(docker inspect \
  --format='{{index .Config.Labels "io.cothrom.db.backup.command"}}' \
  container_name)

# Execute backup
docker exec container_name sh -c "$BACKUP_CMD > /backup/dump.sql"
```

---

### io.cothrom.backup.policy

**Purpose**: Defines backup frequency for automation

**Required**: Recommended for all containers with data

**Values**:
- `daily` - Backup every day (critical data)
- `weekly` - Backup once per week (standard data)
- `monthly` - Backup once per month (archival data)
- `none` - No automated backup needed

**Examples**:
```yaml
labels:
  - io.cothrom.backup.policy="daily"    # Financial/accounting data
  - io.cothrom.backup.policy="weekly"   # Regular application data
  - io.cothrom.backup.policy="monthly"  # Logs or archives
```

---

## Complete Label Examples

### Application Container with Config

```yaml
files_projectsend:
  image: lscr.io/linuxserver/projectsend:latest
  container_name: files_projectsend
  # ... other config ...
  labels:
    - io.cothrom.role="app"
    - io.cothrom.stack="files"
    - io.cothrom.data="true"
    - io.cothrom.data.class="config"
    - io.cothrom.backup.policy="weekly"
```

### Database Container

```yaml
files_db:
  image: mariadb:noble
  container_name: files_db
  # ... other config ...
  labels:
    - io.cothrom.role="database"
    - io.cothrom.stack="files"
    - io.cothrom.data="true"
    - io.cothrom.data.class="database"
    - io.cothrom.db.engine="mysql"
    - io.cothrom.db.backup.command="mysqldump -u $MYSQL_USER -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE"
    - io.cothrom.backup.policy="weekly"
```

### Stateless Worker

```yaml
crm_worker:
  image: twentycrm/twenty:latest
  container_name: crm_worker
  # ... other config ...
  labels:
    - io.cothrom.role="worker"
    - io.cothrom.stack="crm"
    - io.cothrom.data="false"
```

### Cache Service

```yaml
apps_redis:
  image: redis:7-alpine
  container_name: apps_redis
  # ... other config ...
  labels:
    - io.cothrom.role="cache"
    - io.cothrom.stack="apps"
    - io.cothrom.data="false"
```

## Using Labels for Automation

### Query Containers by Label

```bash
# List all database containers
docker ps --filter "label=io.cothrom.role=database"

# List all containers in a stack
docker ps --filter "label=io.cothrom.stack=files"

# List containers needing daily backup
docker ps --filter "label=io.cothrom.backup.policy=daily"

# List all containers with data
docker ps --filter "label=io.cothrom.data=true"
```

### Inspect Labels

```bash
# View all labels for a container
docker inspect --format='{{json .Config.Labels}}' files_projectsend | jq

# Get specific label value
docker inspect \
  --format='{{index .Config.Labels "io.cothrom.backup.policy"}}' \
  files_projectsend
```

### Backup Script Example

```bash
#!/bin/bash
# Automated backup based on labels

# Find all databases needing daily backup
DATABASES=$(docker ps -q --filter "label=io.cothrom.role=database" \
                         --filter "label=io.cothrom.backup.policy=daily")

for DB in $DATABASES; do
  NAME=$(docker inspect --format='{{.Name}}' $DB | tr -d '/')
  STACK=$(docker inspect --format='{{index .Config.Labels "io.cothrom.stack"}}' $DB)
  CMD=$(docker inspect --format='{{index .Config.Labels "io.cothrom.db.backup.command"}}' $DB)
  
  echo "Backing up $NAME..."
  docker exec $DB sh -c "$CMD" > "${BACKUP_DIR}/${STACK}/${NAME}_$(date +%Y%m%d).sql"
done
```

### Monitoring Script Example

```bash
#!/bin/bash
# Check health of all application containers

APPS=$(docker ps -q --filter "label=io.cothrom.role=app")

for APP in $APPS; do
  NAME=$(docker inspect --format='{{.Name}}' $APP | tr -d '/')
  STACK=$(docker inspect --format='{{index .Config.Labels "io.cothrom.stack"}}' $APP)
  HEALTH=$(docker inspect --format='{{.State.Health.Status}}' $APP 2>/dev/null || echo "none")
  
  echo "$STACK/$NAME: $HEALTH"
done
```

## Label Best Practices

### DO:
- ✓ Label every container
- ✓ Use consistent stack names
- ✓ Include backup commands for databases
- ✓ Set appropriate backup policies
- ✓ Document custom labels

### DON'T:
- ✗ Mix label formats
- ✗ Skip required labels
- ✗ Use uppercase in stack names
- ✗ Include secrets in labels (use env vars)
- ✗ Change labels after deployment (breaks automation)

## Adding Custom Labels

You can add custom labels for project-specific needs:

```yaml
labels:
  # Standard Cothrom labels
  - io.cothrom.role="app"
  - io.cothrom.stack="myapp"
  
  # Custom labels (use your own namespace)
  - com.mycompany.environment="production"
  - com.mycompany.team="backend"
  - com.mycompany.version="1.2.3"
```

**Recommendation**: Use your own namespace (e.g., `com.yourcompany.*`) for custom labels to avoid conflicts.

## Future Automation Possibilities

These labels enable:

- **Automated backups** - Schedule backups based on policy
- **Service discovery** - Find services by role or stack
- **Monitoring** - Track health of apps vs workers vs databases
- **Documentation generation** - Auto-generate service maps
- **Cost tracking** - Group resources by stack for billing
- **Compliance** - Identify containers with sensitive data
- **Orchestration** - Rolling updates per role

## Validation

Check that all containers have proper labels:

```bash
# List containers with missing stack labels
docker ps --format "{{.Names}}" | while read name; do
  STACK=$(docker inspect --format='{{index .Config.Labels "io.cothrom.stack"}}' $name 2>/dev/null)
  if [ -z "$STACK" ]; then
    echo "Missing label: $name"
  fi
done
```

## Label Schema

For reference and tooling:

```json
{
  "io.cothrom.role": {
    "type": "string",
    "required": true,
    "enum": ["app", "database", "proxy", "worker", "cache", "storage"]
  },
  "io.cothrom.stack": {
    "type": "string",
    "required": true,
    "pattern": "^[a-z][a-z0-9-]*$"
  },
  "io.cothrom.data": {
    "type": "string",
    "required": true,
    "enum": ["true", "false"]
  },
  "io.cothrom.data.class": {
    "type": "string",
    "required_if": "io.cothrom.data=true",
    "enum": ["database", "files", "config"]
  },
  "io.cothrom.db.engine": {
    "type": "string",
    "required_if": "io.cothrom.role=database",
    "enum": ["postgres", "mysql", "mariadb", "mongodb", "redis", "couchdb", "memcached"]
  },
  "io.cothrom.db.backup.command": {
    "type": "string",
    "required_if": "io.cothrom.role=database"
  },
  "io.cothrom.backup.policy": {
    "type": "string",
    "enum": ["daily", "weekly", "monthly", "none"]
  }
}
```
