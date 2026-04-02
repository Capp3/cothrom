# Getting Started

This guide will help you set up and run the Cothrom self-hosted stack.

## Prerequisites

### System Requirements

- **OS**: Linux (tested on Ubuntu 22.04+)
- **CPU**: 4+ cores recommended
- **RAM**: 8GB minimum, 16GB+ recommended
- **Storage**: 50GB+ for applications, plus data storage needs
- **Docker**: Docker Engine 24.0+ and Docker Compose v2

### Required Software

```bash
# Install Docker (Ubuntu/Debian)
curl -fsSL https://get.docker.com | sh

# Add your user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

## Initial Setup

### 1. Clone the Repository

```bash
git clone <repository-url> cothrom
cd cothrom
```

### 2. Create Environment File

Copy the sample environment file and customize it:

```bash
make dotenv
# or manually:
cp .env.sample .env
```

Edit `.env` with your settings:

```bash
nano .env
```

### 3. Configure Required Variables

At minimum, set these variables in `.env`:

```bash
# User/Group IDs (get with: id)
PUID=1000
PGID=1000

# Timezone
TZ=Europe/London

# Data directories
DATA_DIR=/home/server/.local/data
BACKUP_DIR=/home/server/.local/backups

# Domain (if using Cloudflare tunnel)
DOMAIN=yourdomain.com

# Database passwords (change these!)
APPS_POSTGRES_PASSWORD=secure_password_here
DATA_NOCODB_POSTGRES_PASSWORD=secure_password_here
# ... (update all passwords)
```

See [Environment Variables](configuration/environment.md) for a complete reference.

### 4. Create Data Directories

```bash
mkdir -p ${DATA_DIR}
mkdir -p ${BACKUP_DIR}
chmod 775 ${DATA_DIR}
chmod 775 ${BACKUP_DIR}
```

### 5. Review Stack Configuration

By default, all stacks in `compose.yml` are enabled. To disable stacks, comment them out:

```yaml
include:
  - path: ./docker/accounts.yml
  - path: ./docker/apps.yml
  # - path: ./docker/project.yml  # Disabled
```

Active stacks can be found in the [Active Stacks](stacks/active.md) documentation.

## Starting Services

### First Run

Pull images and start all services:

```bash
# Start all services
make up

# Or manually:
docker compose up -d
```

### Monitor Startup

Check that services are starting correctly:

```bash
# List all containers
make list

# View logs for a specific container
make logs <container_id>

# View all logs
docker compose logs -f
```

### Verify Services

Check service status:

```bash
docker compose ps
```

All services should show as "Up" or "healthy" after a few minutes.

## First-Time Configuration

Many services require initial setup through their web interfaces:

### 1. Dashy Dashboard (Home)

- URL: `http://localhost:${HOME_PORT}` (default: 12108)
- Config file: `config/home/conf.yml`
- Edit the config file to customize your dashboard

### 2. NocoDB (Data)

- URL: `http://localhost:${DATA_PORT}` (default: 12104)
- Create admin account on first visit
- Connect to databases using credentials from `.env`

### 3. Baikal (Calendar/Contacts)

- URL: `http://localhost:${CAL_PORT}` (default: 12103)
- Follow setup wizard
- Connect with CalDAV/CardDAV clients

### 4. Akaunting (Accounts)

- URL: `http://localhost:${ACCOUNTS_PORT}`
- Setup wizard will run on first visit
- Database connection is pre-configured

## Cloudflare Tunnel Setup

If using external access via Cloudflare:

1. Create a tunnel in Cloudflare dashboard
2. Get your tunnel token
3. Add to `.env`: `CLOUDFLARE_TUNNEL_TOKEN=your_token_here`
4. Configure tunnel routes in Cloudflare dashboard to point to services

Example routes:
- `files.yourdomain.com` → `http://files_projectsend:80`
- `data.yourdomain.com` → `http://data_nocodb:8080`
- `cal.yourdomain.com` → `http://cal_baikal:80`

## Common Tasks

### Stop Services

```bash
make down
# or
docker compose stop
```

### Restart Services

```bash
docker compose restart

# Restart specific service
docker compose restart files_projectsend
```

### Update Services

```bash
# Pull latest images
docker compose pull

# Restart with new images
docker compose up -d
```

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f files_projectsend

# Last 100 lines
docker compose logs --tail=100
```

## Troubleshooting

### Container Won't Start

1. Check logs: `docker compose logs <service_name>`
2. Verify environment variables in `.env`
3. Ensure data directories exist and have correct permissions
4. Check for port conflicts: `sudo netstat -tulpn | grep <port>`

### Database Connection Errors

1. Wait for database to be healthy: `docker compose ps`
2. Check database logs: `docker compose logs <db_container>`
3. Verify credentials in `.env` match service configuration
4. Ensure database container is on the same network

### Permission Errors

Ensure `PUID` and `PGID` match your user:

```bash
id
# Set these values in .env
```

Fix directory permissions:

```bash
sudo chown -R $USER:$USER ${DATA_DIR}
sudo chown -R $USER:$USER ${BACKUP_DIR}
```

### Out of Disk Space

Check Docker disk usage:

```bash
docker system df

# Clean up
make clean
# or
docker system prune -a --volumes
```

## Next Steps

- Configure individual services (see service documentation)
- Set up automated backups
- Review [Operations](operations.md) for daily management
- Customize Dashy dashboard in `config/home/conf.yml`

## Getting Help

- Check service-specific logs
- Review [Architecture](architecture.md) to understand system design
- See [Operations](operations.md) for common tasks and troubleshooting
