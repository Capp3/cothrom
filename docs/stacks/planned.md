# Planned Stacks

These stacks are defined but currently commented out in `compose.yml`. They are lower priority or require additional setup time.

## company - Dolibarr ERP/CRM

**Purpose**: Enterprise Resource Planning and Customer Relationship Management

**Status**: ⏸️ Commented out - needs more setup time

**File**: `docker/company.yml`

**Containers**:
- `company_dolibarr` - Dolibarr application
- `company_db` - MariaDB database

**Key Features**:
- ERP functionality
- CRM with lead tracking
- Invoicing and proposals
- Product catalog
- Project management
- Multi-company support

**Volumes**:
- `company_dolibarr_data` - Application data
- `company_db` - Database
- `${BACKUP_DIR}/company/dolibarr` - Backup storage

**To Enable**:

1. Uncomment in `compose.yml`:
   ```yaml
   - path: ./docker/company.yml
   ```

2. Set environment variables in `.env`:
   ```bash
   COMPANY_PORT=12109
   COMPANY_DB_PASSWORD=secure_password
   COMPANY_NAME="Your Company Name"
   ```

3. Start services:
   ```bash
   docker compose up -d company_dolibarr company_db
   ```

---

## grist - Grist Spreadsheet Database

**Purpose**: Spreadsheet-database hybrid with Python formulas

**Status**: ⏸️ Commented out - lower priority (NocoDB provides similar functionality)

**File**: `docker/grist.yml`

**Containers**:
- `grist_grist` - Grist application
- `grist_db` - PostgreSQL database

**Key Features**:
- Spreadsheet interface with relational database backend
- Python formulas and scripts
- Access control and sharing
- API access
- Form builder

**Volumes**:
- `grist_data` - Application data
- `grist_db` - Database
- `${BACKUP_DIR}/grist` - Backup storage

**Environment Variables**:
- `GRIST_PORT` - Port for web access
- `GRIST_SINGLE_ORG` - Organization name
- `GRIST_SESSION_SECRET` - Session encryption key
- `GRIST_POSTGRES_PASSWORD` - Database password

**To Enable**:

1. Uncomment in `compose.yml`:
   ```yaml
   - path: ./docker/grist.yml
   ```

2. Set environment variables in `.env`:
   ```bash
   GRIST_PORT=12107
   GRIST_SINGLE_ORG=myorg
   GRIST_SESSION_SECRET=$(openssl rand -hex 32)
   GRIST_POSTGRES_PASSWORD=secure_password
   ```

3. Start services:
   ```bash
   docker compose up -d
   ```

**Why Not Active**: NocoDB already provides spreadsheet-database functionality with a more modern interface. Grist is kept as an alternative option.

---

## meetings - OpenMeetings

**Purpose**: Web conferencing and collaboration

**Status**: ⏸️ Commented out - needs significant setup time

**File**: `docker/meetings.yml` (currently minimal)

**Note**: This stack is not yet fully defined and requires:
- Database configuration
- Storage volumes
- Networking setup
- TURN/STUN server for WebRTC
- SSL certificates

**Key Features** (when implemented):
- Video conferencing
- Screen sharing
- Whiteboard
- Document collaboration
- Recording capabilities

**To Implement**:

This stack needs a complete implementation before it can be enabled. Consider alternatives:
- Jitsi Meet
- BigBlueButton
- Nextcloud Talk

---

## office - Collabora Online

**Purpose**: Online office suite (LibreOffice in browser)

**Status**: ⏸️ Commented out - needs more setup time

**File**: `docker/office.yml`

**Containers**:
- `office_collabora` - Collabora Online server

**Key Features**:
- Edit Word, Excel, PowerPoint files in browser
- Real-time collaboration
- Integration with file sharing platforms
- Full LibreOffice compatibility

**Volumes**:
- `office_collabora` - Application data
- `${BACKUP_DIR}/office` - Backup storage

**Environment Variables**:
- `OFFICE_PORT` - Port for web access (default: 12110)

**Integration Needed**:

Collabora requires integration with a file storage platform:
- Nextcloud
- ownCloud  
- ProjectSend (limited)

Consider enabling after setting up file storage integration.

**To Enable**:

1. Set up file storage integration
2. Uncomment in `compose.yml`:
   ```yaml
   - path: ./docker/office.yml
   ```

3. Configure environment:
   ```bash
   OFFICE_PORT=12110
   ```

4. Start services:
   ```bash
   docker compose up -d office_collabora
   ```

---

## project - OpenProject

**Purpose**: Project management and collaboration platform

**Status**: ⏸️ Commented out - complex setup with multiple containers

**File**: `docker/project.yml`

**Containers**:
- `project_db` - PostgreSQL database
- `project_cache` - Memcached cache
- `project_proxy` - Caddy reverse proxy
- `project_web` - Web application server
- `project_worker` - Background worker
- `project_cron` - Scheduled tasks
- `project_seeder` - Database seeder
- `project_autoheal` - Container health monitor

**Key Features**:
- Gantt charts and timelines
- Task management
- Wiki and documentation
- Time tracking
- Team collaboration
- Agile boards

**Volumes**:
- `project_pgdata` - Database
- `project_opdata` - Application data
- `${BACKUP_DIR}/project` - Backup storage

**Environment Variables**:
- `PROJECT_PORT` - Port for web access
- `POSTGRES_PASSWORD` - Database password (default: p4ssw0rd)
- `OPENPROJECT_RAILS__RELATIVE__URL__ROOT` - Optional URL prefix

**Complexity Notes**:

This is one of the more complex stacks with:
- Custom proxy configuration
- Multiple worker processes
- Custom build for enterprise features
- Backup/upgrade control containers

**To Enable**:

1. Review `docker/project.yml` configuration
2. Uncomment in `compose.yml`:
   ```yaml
   - path: ./docker/project.yml
   ```

3. Set environment variables:
   ```bash
   PROJECT_PORT=12200
   POSTGRES_PASSWORD=secure_password
   ```

4. Start services:
   ```bash
   docker compose up -d
   ```

5. Wait for seeder to complete initial setup
6. Access at `http://localhost:${PROJECT_PORT}`

---

## Priority Recommendations

Based on functionality overlap and setup complexity:

### High Priority (Enable Soon)
- **company** - Dolibarr provides ERP features not available elsewhere

### Medium Priority
- **project** - Useful if you need project management (alternative: use apps/Budibase to build custom PM)
- **office** - Enable if you need online document editing with ProjectSend integration

### Low Priority
- **grist** - NocoDB already provides similar functionality
- **meetings** - Needs complete rebuild; consider alternatives

### Needs Work
- **meetings** - Requires full implementation before enabling

---

## Enabling Planned Stacks

General process:

1. Uncomment the stack in `compose.yml`
2. Add required environment variables to `.env`
3. Create data directories if using bind mounts
4. Review stack-specific documentation
5. Start services: `docker compose up -d`
6. Monitor logs: `docker compose logs -f <container>`
7. Complete initial setup via web interface
8. Update [active.md](active.md) documentation

See [Service Templates](../service_templates.md) for adding completely new services.
