# Operations

This guide covers day-to-day operations, commands, and troubleshooting for the Cothrom stack.

## Daily Operations

### Starting Services

```bash
# Start all services
make up

# Or manually
docker compose up -d
```

The `-d` flag runs containers in detached mode (background).

---

### Stopping Services

```bash
# Stop all services (containers remain)
make down

# Or manually
docker compose stop
```

---

### Restarting Services

```bash
# Restart all services
docker compose restart

# Restart specific service
docker compose restart files_projectsend

# Restart specific stack (example: all files containers)
docker compose restart files_projectsend files_db
```

---

### Viewing Logs

```bash
# List all containers with IDs
make list

# View logs for specific container
make logs <container_id>

# Or with docker compose
docker compose logs -f files_projectsend

# View logs for all services
docker compose logs -f

# Last 100 lines
docker compose logs --tail=100

# Follow logs since specific time
docker compose logs --since 30m -f
```

---

### Checking Status

```bash
# View all container status
docker compose ps

# View specific service
docker compose ps files_projectsend

# Check health status
docker compose ps --format json | jq '.[] | {name: .Name, health: .Health}'
```

---

### Accessing Container Shell

```bash
# List containers
make list

# Execute shell in container
make exec <container_id>

# Or manually
docker exec -it files_projectsend sh

# For containers with bash
docker exec -it files_projectsend bash
```

---

## Make Commands Reference

The project includes a `Makefile` with convenient commands:

| Command | Description |
|---------|-------------|
| `make help` | Show available commands |
| `make dotenv` | Create `.env` from `.env.sample` |
| `make up` | Start all services |
| `make down` | Stop all services |
| `make list` | List all containers (name and ID) |
| `make logs <id>` | Show logs for specific container |
| `make exec <id>` | Execute shell in container |
| `make clean` | Clean temporary files and prune Docker |
| `make vibe` | Install cursor rules and memory bank |
| `make update-memory-bank` | Update cursor memory bank |
| `make update-rules` | Update cursor rules |

**Note**: Some Makefile targets reference a `hosts/` directory that doesn't exist. These are legacy targets and should be ignored:
- `make status`
- `make pull`
- `make push`
- `make restart`
- `make host-logs`

Use the equivalent `docker compose` commands instead.

---

## Service Management

### Updating Services

```bash
# Pull latest images
docker compose pull

# Recreate containers with new images
docker compose up -d

# For specific service
docker compose pull files_projectsend
docker compose up -d files_projectsend
```

---

### Adding New Services

1. Create `docker/newservice.yml` following [Service Templates](service_templates.md)
2. Add to `compose.yml`:
   ```yaml
   include:
     - path: ./docker/newservice.yml
   ```
3. Add environment variables to `.env`
4. Start service:
   ```bash
   docker compose up -d
   ```

---

### Disabling Services

1. Comment out in `compose.yml`:
   ```yaml
   # - path: ./docker/office.yml
   ```
2. Stop and remove containers:
   ```bash
   docker compose down office_collabora
   ```
3. Restart remaining services:
   ```bash
   docker compose up -d
   ```

---

## Backup and Restore

### Automated Backup Scripts

The project includes label-based backup scripts in `scripts/`:

```bash
# Run all backups (databases + config + rotation)
./scripts/backup-all.sh

# Or run individually
./scripts/backup-databases.sh
./scripts/backup-configs.sh
./scripts/rotate-backups.sh
```

See [scripts/README.md](../scripts/README.md) for full documentation, cron setup, and error notification on terminal startup.

### Manual Database Backups

#### PostgreSQL

```bash
# Backup
docker exec data_nocodb_db pg_dump -U postgres -d data_nocodb_db > backup.sql

# Restore
docker exec -i data_nocodb_db psql -U postgres -d data_nocodb_db < backup.sql
```

#### MySQL/MariaDB

```bash
# Backup
docker exec files_db mysqldump -u projectsend -p files_projectsend > backup.sql

# Restore
docker exec -i files_db mysql -u projectsend -p files_projectsend < backup.sql
```

### Volume Backups

```bash
# Backup named volume
docker run --rm \
  -v files_config:/source:ro \
  -v ${BACKUP_DIR}/files:/backup \
  alpine tar czf /backup/files_config_$(date +%Y%m%d).tar.gz -C /source .

# Restore named volume
docker run --rm \
  -v files_config:/target \
  -v ${BACKUP_DIR}/files:/backup \
  alpine tar xzf /backup/files_config_20240115.tar.gz -C /target
```

---

## Monitoring

### Resource Usage

```bash
# Real-time stats for all containers
docker stats

# Specific container
docker stats files_projectsend

# One-time snapshot
docker stats --no-stream
```

### Disk Usage

```bash
# Docker disk usage summary
docker system df

# Detailed breakdown
docker system df -v

# Check volume sizes
docker volume ls -q | xargs docker volume inspect | \
  jq -r '.[] | [.Name, .Mountpoint] | @tsv'
```

### Health Checks

```bash
# View health status
docker ps --format "table {{.Names}}\t{{.Status}}"

# Check specific container health
docker inspect --format='{{.State.Health.Status}}' files_projectsend

# View health check logs
docker inspect --format='{{json .State.Health}}' files_projectsend | jq
```

---

## Troubleshooting

### Container Won't Start

**Symptoms**: Container keeps restarting or exits immediately

**Diagnosis**:
```bash
# View recent logs
docker compose logs --tail=50 <service>

# Check exit code
docker inspect --format='{{.State.ExitCode}}' <container>

# View error details
docker inspect --format='{{.State.Error}}' <container>
```

**Common Causes**:
1. **Configuration error**: Check env vars in `.env`
2. **Port conflict**: Another service using the same port
3. **Missing dependency**: Database not ready yet
4. **Permission error**: Can't write to volume

**Solutions**:
```bash
# Check port conflicts
sudo netstat -tulpn | grep <port>

# Verify environment variables
docker compose config | grep <SERVICE>

# Check volume permissions
ls -la ${DATA_DIR}/<stack>

# Wait for database to be healthy
docker compose ps | grep -i healthy
```

---

### Database Connection Errors

**Symptoms**: App can't connect to database

**Diagnosis**:
```bash
# Check if database is running
docker compose ps | grep _db

# Check database logs
docker compose logs <database_container>

# Verify network connectivity
docker compose exec <app> ping <database_container>
```

**Solutions**:
```bash
# Ensure database is healthy
docker compose restart <database>

# Wait for healthcheck
docker compose ps

# Verify credentials in .env
grep DB_PASSWORD .env

# Check database is on correct network
docker inspect <database> | jq '.[].NetworkSettings.Networks'
```

---

### Permission Denied Errors

**Symptoms**: Container can't read/write files

**Diagnosis**:
```bash
# Check ownership
ls -la ${DATA_DIR}
ls -la ${BACKUP_DIR}

# Check PUID/PGID
docker compose exec <service> id
```

**Solutions**:
```bash
# Fix ownership
sudo chown -R $(id -u):$(id -g) ${DATA_DIR}
sudo chown -R $(id -u):$(id -g) ${BACKUP_DIR}

# Set PUID/PGID in .env
echo "PUID=$(id -u)" >> .env
echo "PGID=$(id -g)" >> .env

# Restart container
docker compose up -d <service>
```

---

### Out of Disk Space

**Symptoms**: Containers fail with disk space errors

**Diagnosis**:
```bash
# Check host disk space
df -h

# Check Docker disk usage
docker system df
```

**Solutions**:
```bash
# Clean up Docker resources
make clean

# Or manually:
docker system prune -a --volumes

# Remove specific stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Remove unused volumes (CAREFUL!)
docker volume prune
```

---

### Network Issues

**Symptoms**: Services can't communicate

**Diagnosis**:
```bash
# List networks
docker network ls

# Inspect network
docker network inspect cothrom_frontend

# Check which containers are on network
docker network inspect cothrom_frontend | jq '.[].Containers'
```

**Solutions**:
```bash
# Reconnect container to network
docker network connect cothrom_frontend <container>

# Recreate networks
docker compose down
docker compose up -d
```

---

### Slow Performance

**Diagnosis**:
```bash
# Check resource usage
docker stats --no-stream

# Check system load
uptime
top
```

**Common Causes**:
1. Insufficient RAM
2. Disk I/O bottleneck
3. Too many services running
4. Database needs optimization

**Solutions**:
- Disable unused stacks
- Add more RAM
- Move data to faster disk
- Optimize database queries
- Check for runaway processes

---

## Maintenance

### Regular Maintenance Tasks

**Daily**:
- Check container health: `docker compose ps`
- Review logs for errors: `docker compose logs --since 24h | grep -i error`
- Monitor disk space: `df -h`

**Weekly**:
- Update images: `docker compose pull && docker compose up -d`
- Backup databases (see [Backup](#backup-and-restore))
- Clean up old logs: `make clean`

**Monthly**:
- Review resource usage: `docker stats`
- Archive old backups
- Check for security updates
- Review and update `.env` passwords

### Cleanup Commands

```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune -a

# Remove unused volumes (CAREFUL - deletes data!)
docker volume prune

# Remove unused networks
docker network prune

# Full cleanup (CAREFUL!)
docker system prune -a --volumes

# Safe cleanup (keeps volumes)
make clean
```

---

## Security

### Updating Passwords

1. Stop affected service:
   ```bash
   docker compose stop <service>
   ```

2. Update `.env`:
   ```bash
   nano .env  # Change password
   ```

3. Update database if needed:
   ```bash
   docker compose exec <db> psql -U postgres
   # ALTER USER postgres PASSWORD 'newpassword';
   ```

4. Restart service:
   ```bash
   docker compose up -d <service>
   ```

### Viewing Secrets (Safely)

```bash
# View specific env var (doesn't show in history if spaced)
 grep PASSWORD .env

# View all secrets
cat .env | grep -i password

# Check what container sees
docker compose exec <service> env | grep PASSWORD
```

### Security Best Practices

- ✓ Use strong passwords (16+ characters)
- ✓ Different passwords for each service
- ✓ Never commit `.env` to git
- ✓ Restrict file permissions: `chmod 600 .env`
- ✓ Use Cloudflare tunnel for external access
- ✓ Keep images updated
- ✓ Review logs regularly
- ✓ Limit port exposure (only localhost)

---

## Getting Help

### Useful Commands

```bash
# View parsed configuration
docker compose config

# Validate compose file
docker compose config --quiet

# View version info
docker compose version
docker --version

# View container details
docker inspect <container> | jq
```

### Log Collection

When reporting issues, collect:

```bash
# Service status
docker compose ps > status.txt

# Logs
docker compose logs --tail=200 <service> > logs.txt

# Configuration (sanitize passwords!)
docker compose config > config.txt

# System info
docker version > sysinfo.txt
docker info >> sysinfo.txt
```

### Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Getting Started](getting-started.md) - Initial setup
- [Architecture](architecture.md) - System design
- [Configuration](configuration/) - Settings reference
- Service-specific documentation in [stacks/](stacks/)
