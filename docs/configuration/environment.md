# Environment Variables

Complete reference for all environment variables used in the Cothrom project.

## Configuration File

All environment variables are stored in `.env` in the project root.

**⚠️ Security**: Never commit `.env` to version control! It contains passwords and secrets.

## Creating Your Environment File

```bash
# Copy the sample
cp .env.sample .env

# Edit with your values
nano .env
```

## System Variables

### User and Group IDs

```bash
PUID=1000
PGID=1000
```

**Purpose**: Set the user/group ID for processes running in containers

**How to find your values**:
```bash
id
# Output: uid=1000(username) gid=1000(username) ...
```

**Why it matters**: Ensures containers can write to bind mounts with correct permissions

---

### Timezone

```bash
TZ=Etc/UTC
```

**Purpose**: Set the timezone for all containers

**Common values**:
- `America/New_York`
- `Europe/London`
- `Asia/Tokyo`
- `Australia/Sydney`

**Find your timezone**: `timedatectl` or see [List of tz database time zones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)

---

### Storage Paths

```bash
BACKUP_DIR=/home/server/.local/backups
DATA_DIR=/home/server/.local/data
```

**Purpose**: Define where application data and backups are stored

**Requirements**:
- Must be absolute paths
- Directories must exist
- Must be writable by the user (PUID/PGID)

**Setup**:
```bash
mkdir -p /home/server/.local/data
mkdir -p /home/server/.local/backups
chmod 775 /home/server/.local/data
chmod 775 /home/server/.local/backups
```

---

### Domain

```bash
DOMAIN=mydomain.eu
```

**Purpose**: Base domain for services when using Cloudflare tunnel or reverse proxy

**Usage**: Services become accessible at:
- `https://files.${DOMAIN}`
- `https://data.${DOMAIN}`
- `https://cal.${DOMAIN}`

---

## Port Assignments

Each service exposes a port on localhost for local access.

```bash
APPS_PORT=12101
APPS_PORT_SSL=12102
CAL_PORT=12103
DATA_PORT=12104
FILES_PORT=12105
GRAMMAR_PORT=12106
GRIST_PORT=12107
HOME_PORT=12108
MEETINGS_PORT=12109
OFFICE_PORT=12110
```

**Port Range**: 12100-12199 reserved for Cothrom services

**Check for conflicts**:
```bash
sudo netstat -tulpn | grep 12100
```

---

## Service-Specific Variables

### Accounts (Akaunting)

```bash
ACCOUNTS_PORT=<port>
ACCOUNTS_DB_PASSWORD=<password>
ACCOUNTS_ADMIN_PASSWORD=<password>
LOCALE=en-US
COMPANY_NAME="Your Company Name"
```

**Notes**:
- `LOCALE`: Language code (en-US, en-GB, de-DE, etc.)
- `COMPANY_NAME`: Your company name for documents

---

### Apps (Budibase)

```bash
APPS_PORT=12101
APPS_PORT_SSL=12102
APPS_MONGODB_ROOT_PASSWORD=<password>
APPS_ENCRYPTION_PASSWORD=<password>
APPS_POSTGRES_PASSWORD=<password>

# Budibase specific
APPS_COUCH_DB_PASSWORD=<password>
APPS_MINIO_ACCESS_KEY=<key>
APPS_MINIO_SECRET_KEY=<secret>
APPS_INTERNAL_API_KEY=<key>
APPS_API_ENCRYPTION_KEY=<key>
APPS_JWT_SECRET=<secret>
APPS_BB_ADMIN_USER_EMAIL=<email>
APPS_BB_ADMIN_USER_PASSWORD=<password>
APPS_BUDIBASE_ENVIRONMENT=production
APPS_OFFLINE_MODE=

# Redis (optional)
REDIS_PASSWORD=
REDIS_USERNAME=
```

**Generate secrets**:
```bash
openssl rand -hex 32  # For encryption keys and JWT secrets
openssl rand -hex 16  # For passwords
```

**Notes**:
- `APPS_OFFLINE_MODE`: Set to `1` to disable telemetry
- Leave `REDIS_PASSWORD` empty if not using Redis authentication

---

### Calendar (Baikal)

```bash
CAL_PORT=12103
CAL_POSTGRES_PASSWORD=<password>
```

**Notes**:
- Initial setup done via web interface
- Database credentials are auto-configured

---

### CRM (Twenty)

```bash
CRM_TAG=latest
CRM_SERVER_PORT=<port>
CRM_DATABASE_PASSWORD=<password>
CRM_APP_SECRET=<secret>

# Email configuration
EMAIL_FROM_ADDRESS=contact@yourdomain.com
EMAIL_FROM_NAME="John from YourDomain"
EMAIL_SYSTEM_ADDRESS=system@yourdomain.com
EMAIL_DRIVER=smtp
EMAIL_SMTP_HOST=smtp.gmail.com
EMAIL_SMTP_PORT=465
EMAIL_SMTP_USER=
EMAIL_SMTP_PASSWORD=
```

**Email drivers**: `smtp`, `logger` (logs instead of sending)

**Generate APP_SECRET**:
```bash
openssl rand -hex 32
```

---

### Data (NocoDB)

```bash
DATA_PORT=12104
DATA_NOCODB_POSTGRES_PASSWORD=<password>
DATA_NOCODB_POSTGRES_USER=data_nocodb

# pgAdmin
PGADMIN_PORT=<port>
PGADMIN_ADMIN_EMAIL=admin@example.com
PGADMIN_ADMIN_PASSWORD=<password>
```

**Datastorage databases** (project-specific):
```bash
DATA_DATA_NOCODB_POSTGRES_PASSWORD=<password>
DATA_DATA_NOCODB_POSTGRES_USER=data_nocodb_data

DATA_ASSDISASTER_POSTGRES_PASSWORD=<password>
DATA_ASSDISASTER_POSTGRES_USER=<user>

DATA_FINEOPINION_POSTGRES_PASSWORD=<password>
DATA_FINEOPINION_POSTGRES_USER=<user>

DATA_AWESOME_POSTGRES_PASSWORD=<password>
DATA_AWESOME_POSTGRES_USER=<user>

DATA_NOCODB_NIA_CR_POSTGRES_PASSWORD=<password>
DATA_NOCODB_NIA_CDN_POSTGRES_PASSWORD=<password>
DATA_NOCODB_NIA_VCASOD_POSTGRES_PASSWORD=<password>
DATA_NOCODB_COTHOM_TRACKING_POSTGRES_PASSWORD=<password>
DATA_NOCODB_COTHOM_TRACKING_POSTGRES_USER=<user>
DATA_NOCODB_COTHOM_TRACKING_POSTGRES_DB_NAME=<dbname>
DATA_NOCODB_ELECTRONOISE_POSTGRES_PASSWORD=<password>
DATA_NOCODB_ONTIME_POSTGRES_PASSWORD=<password>
DATA_NOCODB_NIA_INQUIRIES_POSTGRES_PASSWORD=<password>
```

---

### Documents (Etherpad)

```bash
DOCUMENTS_PORT=<port>
DOCUMENTS_ADMIN_PASSWORD=<password>
DOCUMENTS_DB_PASSWORD=<password>

# Optional: OpenRouter LLM integration
OPENROUTER_API_KEY=
DOCUMENTS_LLM_MODEL=anthropic/claude-3.5-sonnet
```

**LLM Models** (if using OpenRouter):
- `anthropic/claude-3.5-sonnet`
- `openai/gpt-4`
- `openai/gpt-3.5-turbo`

---

### Draw (Excalidraw)

```bash
DRAW_PORT=<port>
```

**Notes**: Minimal configuration needed

---

### Files (ProjectSend)

```bash
FILES_PORT=12105
FILES_DB_PASSWORD=<password>
```

**Notes**:
- Initial setup via web interface
- Database connection auto-configured

---

### Grammar (LanguageTool)

```bash
GRAMMAR_PORT=12106
GRAMMAR_LOCALE_LANGUAGE=en_GB.UTF-8
GRAMMAR_LANGTOOL_LANGUAGE=en_GB:en
GRAMMAR_DOWNLOAD_NGRAM_LANGS=
```

**Language codes**:
- `en_GB` - British English
- `en_US` - American English
- `de_DE` - German
- `fr_FR` - French
- `es_ES` - Spanish

**N-gram datasets** (optional, large downloads):
- `en` - English n-grams (~8GB)
- `de` - German n-grams
- Leave empty to skip

---

### Grist (if enabled)

```bash
GRIST_PORT=12107
GRIST_SINGLE_ORG=myorg
GRIST_SESSION_SECRET=<secret>
GRIST_POSTGRES_PASSWORD=<password>
```

**Generate session secret**:
```bash
openssl rand -hex 32
```

---

### Home (Dashy)

```bash
HOME_PORT=12108
```

**Notes**:
- Configuration in `config/home/conf.yml`
- No database needed

---

### PDF (Stirling PDF)

```bash
PDF_PORT=<port>
```

**Notes**: Minimal configuration needed

---

### Pi (Glance)

```bash
PI_GLANCES_PORT=<port>
PI_GLANCES_SECRET_TOKEN=<token>
```

**Notes**:
- Configuration in `config/pi_home/glance.yml`
- Token used for API access

---

### Project (OpenProject - if enabled)

```bash
PROJECT_PORT=<port>
POSTGRES_PASSWORD=p4ssw0rd
OPENPROJECT_RAILS__RELATIVE__URL__ROOT=
```

**Notes**:
- Complex multi-container setup
- See OpenProject docs for advanced config

---

### Company (Dolibarr - if enabled)

```bash
COMPANY_PORT=<port>
COMPANY_DB_PASSWORD=<password>
```

---

### Office (Collabora - if enabled)

```bash
OFFICE_PORT=12110
```

---

## External Services

### Cloudflare Tunnel

```bash
CLOUDFLARE_TUNNEL_TOKEN=<your-tunnel-token>
```

**How to get token**:
1. Create tunnel in Cloudflare dashboard
2. Copy the token
3. Add to `.env`

**Configure routes** in Cloudflare dashboard:
- `files.yourdomain.com` → `http://files_projectsend:80`
- `data.yourdomain.com` → `http://data_nocodb:8080`

---

## Password Security

### Generating Secure Passwords

```bash
# 32-character hex string (good for API keys, secrets)
openssl rand -hex 32

# 16-character hex string (good for passwords)
openssl rand -hex 16

# Random password with special characters
openssl rand -base64 24
```

### Password Requirements

- **Minimum length**: 16 characters recommended
- **Complexity**: Mix of letters, numbers, symbols
- **Uniqueness**: Different password for each service
- **Storage**: Only in `.env` file, never in code or compose files

---

## Environment File Template

See `.env.sample` for a complete template with all variables.

**After creating `.env`**:

1. Replace all `monkeybutts` with secure passwords
2. Set your actual domain
3. Verify paths exist
4. Set correct PUID/PGID
5. Choose timezone

---

## Verifying Configuration

Check your configuration:

```bash
# View parsed compose file with variables substituted
docker compose config

# Check for undefined variables
docker compose config --quiet

# List all environment variables in a container
docker compose run --rm <service> env
```

---

## Troubleshooting

### Variable Not Substituted

**Problem**: Seeing `${VARIABLE_NAME}` in container instead of value

**Causes**:
1. Variable not defined in `.env`
2. Syntax error in `.env`
3. Variable not exported

**Solution**:
```bash
# Check .env syntax
cat .env | grep VARIABLE_NAME

# Verify docker compose sees it
docker compose config | grep VARIABLE_NAME
```

### Permission Denied

**Problem**: Containers can't access `${DATA_DIR}` or `${BACKUP_DIR}`

**Solution**:
```bash
# Check ownership
ls -la ${DATA_DIR}

# Fix permissions
sudo chown -R $(id -u):$(id -g) ${DATA_DIR}
sudo chown -R $(id -u):$(id -g) ${BACKUP_DIR}

# Verify PUID/PGID match
id
grep PUID .env
```

### Port Already in Use

**Problem**: `port is already allocated`

**Solution**:
```bash
# Find what's using the port
sudo netstat -tulpn | grep <port>

# Change port in .env
nano .env  # Change PORT variable

# Restart
docker compose up -d
```
