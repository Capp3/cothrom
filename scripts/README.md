# Cothrom Backup Scripts

Backup scripts that use Docker labels (`io.cothrom.*`) to discover and backup database containers and project config. POSIX sh compatible for cron.

## Scripts

| Script | Purpose |
|--------|---------|
| `backup-databases.sh` | Dump all database containers with `io.cothrom.role=database`, `io.cothrom.data=true`, and `io.cothrom.db.backup.command` |
| `backup-configs.sh` | Backup project `config/` directory (Dashy, Glance, etc.) |
| `rotate-backups.sh` | Prune backup files older than retention period |
| `backup-all.sh` | Wrapper: runs databases, configs, then rotation |

## Environment Variables

| Variable | Default | Description |
|----------|---------|--------------|
| `BACKUP_DIR` | `$HOME/backups` | Where to store backups |
| `BACKUP_RETENTION_DAYS` | `7` | Delete backups older than N days. Set to `0` to disable rotation |
| `COTHROM_BACKUP_ERROR_FILE` | `$HOME/.cothrom-backup-errors` | File to append errors (displayed on terminal startup) |

## Usage

```sh
# Run all backups (recommended)
./scripts/backup-all.sh

# Run individual scripts
BACKUP_DIR=~/backups ./scripts/backup-databases.sh
BACKUP_DIR=~/backups ./scripts/backup-configs.sh
BACKUP_DIR=~/backups ./scripts/rotate-backups.sh

# Custom retention (14 days)
BACKUP_RETENTION_DAYS=14 ./scripts/backup-all.sh

# Disable rotation
BACKUP_RETENTION_DAYS=0 ./scripts/backup-all.sh
```

## Cron

Run daily at 2am:

```sh
0 2 * * * BACKUP_DIR=$HOME/backups /home/server/code/cothrom/scripts/backup-all.sh >> /var/log/cothrom-backup.log 2>&1
```

Or with custom retention:

```sh
0 2 * * * BACKUP_DIR=$HOME/backups BACKUP_RETENTION_DAYS=14 /home/server/code/cothrom/scripts/backup-all.sh >> /var/log/cothrom-backup.log 2>&1
```

Ensure the user has Docker access (typically add to `docker` group).

## Backup Directory Layout

```
~/backups/
├── accounts/
│   └── accounts_akaunting-db_20240115-020000.sql
├── cal/
│   └── cal_db_20240115-020000.sql
├── config/
│   └── config_20240115-020000.tar.gz
├── crm/
│   └── crm_db_20240115-020000.sql
├── data/
├── datastorage/
├── documents/
├── files/
└── ...
```

## Error Notification on Terminal Startup

When backups fail, errors are appended to `~/.cothrom-backup-errors`. Add this to your `.bashrc`, `.zshrc`, or `.profile` to display them when opening a new terminal:

```sh
# Cothrom backup error notification
if [ -f "$HOME/.cothrom-backup-errors" ] && [ -s "$HOME/.cothrom-backup-errors" ]; then
  echo ""
  echo "=== Cothrom backup errors ==="
  cat "$HOME/.cothrom-backup-errors"
  echo "=========================================="
  : > "$HOME/.cothrom-backup-errors"
fi
```

Errors are cleared after display. Re-run the backup to fix issues.

## Rotation

- Default: keep 7 days of backups
- Set `BACKUP_RETENTION_DAYS=14` for 2 weeks
- Set `BACKUP_RETENTION_DAYS=0` to disable (no pruning)
- Rotation runs after backups in `backup-all.sh`

## Prerequisites

- Docker installed and running
- User in `docker` group (or root)
- Run from project directory (for config backup) or ensure scripts can find project root

## Troubleshooting

**Empty backups**: Check that database containers have correct `io.cothrom.db.backup.command` labels. MySQL/MariaDB may need `MYSQL_ROOT_PASSWORD` in environment; some images use `MYSQL_RANDOM_ROOT_PASSWORD` which can complicate backups.

**Permission denied**: Ensure `BACKUP_DIR` exists and is writable. Create with `mkdir -p ~/backups`.

**No containers found**: Verify containers are running (`docker compose ps`) and have the required labels.
