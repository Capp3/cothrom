# Active Stacks

These stacks are currently enabled in `compose.yml` and deployed in the Cothrom environment.

## accounts - Akaunting Accounting

**Purpose**: Double-entry accounting and financial management

**Containers**:
- `accounts_akaunting` - Akaunting application
- `accounts_akaunting-db` - MariaDB database

**Access**: `http://localhost:${ACCOUNTS_PORT}` or `https://accounts.${DOMAIN}`

**Key Features**:
- Invoicing and billing
- Expense tracking
- Multi-currency support
- Financial reports

**Volumes**:
- `accounts_akaunting_data` - Application data
- `accounts_akaunting_db` - Database
- `${BACKUP_DIR}/accounts` - Backup storage

---

## apps - Budibase Low-Code Platform

**Purpose**: Build internal tools and business applications without code

**Containers**:
- `apps_budibase` - Main application server
- `apps_worker_budibase` - Background worker
- `apps_minio` - Object storage (S3-compatible)
- `apps_couchdb` - CouchDB database
- `apps_redis` - Redis cache

**Access**: `http://localhost:${APPS_PORT}` or `https://apps.${DOMAIN}`

**Key Features**:
- Visual app builder
- Database integration
- REST API connector
- Custom workflows
- User management

**Networks**: frontend, backend, database

---

## cal - Baikal Calendar & Contacts

**Purpose**: CalDAV and CardDAV server for calendar and contact synchronization

**Containers**:
- `cal_baikal` - Baikal server (nginx)
- `cal_db` - PostgreSQL database

**Access**: `http://localhost:${CAL_PORT}` or `https://cal.${DOMAIN}`

**Client Support**:
- CalDAV URL: `https://cal.${DOMAIN}/dav.php`
- CardDAV URL: `https://cal.${DOMAIN}/dav.php`
- Compatible with Thunderbird, Apple Calendar, Android, iOS

**Volumes**:
- `cal_config` - Server configuration
- `cal_data` - Calendar/contact data
- `cal_db` - Database
- `${BACKUP_DIR}/cal` - Backup storage

---

## crm - Twenty CRM

**Purpose**: Open-source customer relationship management

**Containers**:
- `crm_server` - Twenty CRM application
- `crm_worker` - Background job processor
- `crm_db` - PostgreSQL database
- `crm_redis` - Redis cache

**Access**: `http://localhost:${CRM_SERVER_PORT}` or `https://crm.${DOMAIN}`

**Key Features**:
- Contact management
- Deal pipeline
- Email integration
- Task tracking
- Custom fields

**Volumes**:
- `crm-server-local-data` - Application data
- `${BACKUP_DIR}/crm/server` - Backup storage

**Environment Variables**:
- `CRM_TAG` - Docker image tag (default: latest)
- `CRM_DATABASE_PASSWORD` - Database password
- `CRM_APP_SECRET` - Application secret key

---

## data - NocoDB & Database Management

**Purpose**: Airtable-like interface for databases, plus PostgreSQL admin tools

**Containers**:
- `data_nocodb` - NocoDB application
- `data_nocodb_db` - PostgreSQL database for NocoDB metadata
- `data_pgadmin` - pgAdmin web interface
- Multiple project-specific databases (via `datastorage.yml`)

**Access**:
- NocoDB: `http://localhost:${DATA_PORT}` or `https://data.${DOMAIN}`
- pgAdmin: `http://localhost:${PGADMIN_PORT}`

**Key Features**:
- Spreadsheet-like database interface
- API generation
- Webhooks and automation
- Role-based access control
- Database administration via pgAdmin

**Project Databases** (from datastorage.yml):
- `data_nocodb_assdisaster_db`
- `data_nocodb_fineopinion_db`
- `data_nocodb_awesome_db`
- `data_nocodb_nia_cr_db`
- `data_nocodb_nia_cdn_db`
- `data_nocodb_nia_vcasod_db`
- `data_nocodb_cothom_tracking_db`
- `data_nocodb_electronoise_db`
- `data_nocodb_ontime_db`
- `data_nocodb_nia_inquiries_db`

---

## documents - Etherpad Collaborative Editing

**Purpose**: Real-time collaborative document editing

**Containers**:
- `documents-etherpad` - Etherpad application (custom build)
- `documents-postgres` - PostgreSQL database

**Access**: `http://localhost:${DOCUMENTS_PORT}` or `https://documents.${DOMAIN}`

**Key Features**:
- Real-time collaboration
- Document export (PDF, Word, etc.)
- Plugin support
- LibreOffice integration (for exports)
- LLM integration (OpenRouter)

**Volumes**:
- `${DATA_DIR}/documents/exports` - Exported documents
- `${DATA_DIR}/documents/backups` - Backup storage
- `documents_etherpad-var` - Application state
- Custom settings via `docker/build/documents/etherpad.settings.json`

**Custom Build**: Uses custom Dockerfile with plugins and LibreOffice

---

## draw - Excalidraw Drawing Tool

**Purpose**: Virtual whiteboard for sketching diagrams

**Containers**:
- `draw_excalidraw` - Excalidraw application

**Access**: `http://localhost:${DRAW_PORT}` or `https://draw.${DOMAIN}`

**Key Features**:
- Hand-drawn style diagrams
- Real-time collaboration
- Export to PNG, SVG, JSON
- Open-source whiteboard

**Volumes**:
- `draw_excalidraw` - Drawing data

---

## files - ProjectSend File Sharing

**Purpose**: Self-hosted file sharing and client portal

**Containers**:
- `files_projectsend` - ProjectSend application
- `files_db` - MariaDB database

**Access**: `http://localhost:${FILES_PORT}` or `https://files.${DOMAIN}`

**Key Features**:
- Upload files for clients
- Client accounts with access controls
- Download tracking
- Email notifications
- Branding customization

**Volumes**:
- `files_config` - Application configuration
- `files_db` - Database
- `${DATA_DIR}/files` - Uploaded files
- `${BACKUP_DIR}/files` - Backup storage

---

## grammar - LanguageTool Grammar Checker

**Purpose**: Grammar and spelling checker API

**Containers**:
- `grammar_languagetool` - LanguageTool server (custom build)

**Access**: `http://localhost:${GRAMMAR_PORT}` (API endpoint)

**Key Features**:
- Grammar checking for 20+ languages
- Spelling correction
- Style suggestions
- REST API
- Optional n-gram datasets for better suggestions

**Environment Variables**:
- `GRAMMAR_LOCALE_LANGUAGE` - Locale (e.g., en_GB.UTF-8)
- `GRAMMAR_LANGTOOL_LANGUAGE` - Language codes (e.g., en_GB:en)
- `GRAMMAR_DOWNLOAD_NGRAM_LANGS` - Optional n-gram data

**Custom Build**: Uses custom Dockerfile with optimizations

---

## home - Dashy Dashboard

**Purpose**: Homepage dashboard for all services

**Containers**:
- `home_dashy` - Dashy application

**Access**: `http://localhost:${HOME_PORT}` or `https://home.${DOMAIN}`

**Key Features**:
- Service overview
- Quick links
- Status checks
- Widgets
- Customizable themes

**Configuration**:
- Edit `config/home/conf.yml` to customize dashboard
- See `config/home/README.md` for detailed configuration guide
- JSON Schema validation available

**Volumes**:
- `../config/home/` - Configuration files (bind mount)

---

## pdf - Stirling PDF Tools

**Purpose**: PDF manipulation and processing

**Containers**:
- `pdf_stirling-pdf` - Stirling PDF application

**Access**: `http://localhost:${PDF_PORT}` or `https://pdf.${DOMAIN}`

**Key Features**:
- Merge/split PDFs
- Rotate/crop pages
- Convert formats
- OCR
- Compress PDFs
- Add watermarks
- Fill forms

**Volumes**:
- `pdf_stirling-pdf` - Configuration

---

## pi - Glance Monitoring Dashboard

**Purpose**: System monitoring and service status dashboard

**Containers**:
- `pi_glance` - Glance application

**Access**: `http://localhost:${PI_GLANCES_PORT}` or `https://pi.${DOMAIN}`

**Key Features**:
- Docker container monitoring
- System metrics
- Custom widgets
- Feed aggregation

**Configuration**:
- Edit `config/pi_home/glance.yml` for dashboard setup
- See Glance documentation for widget options

**Volumes**:
- `../config/pi_home` - Configuration
- `../config/pi_assets` - Custom assets
- `/var/run/docker.sock` - Docker API access (read-only)

---

## Infrastructure Services

### cloudflare-tunnel

**Purpose**: Secure external access without port forwarding

**Container**: `cloudflare-tunnel`

**Function**:
- Provides HTTPS access to all services via Cloudflare
- No firewall configuration needed
- Automatic SSL certificates

**Configuration**:
- Set `CLOUDFLARE_TUNNEL_TOKEN` in `.env`
- Configure routes in Cloudflare dashboard

---

## Network Overview

All active stacks connect to one or more networks:

- **frontend**: Web-accessible services
- **backend**: Background workers
- **database**: Database services
- **ingress**: Cloudflare tunnel entry point

See [Architecture](../architecture.md) for network diagrams.
