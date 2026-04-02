#!/bin/sh
#
# rotate-backups.sh - Prune backup files older than BACKUP_RETENTION_DAYS
# Deletes *.sql and *.tar.gz files in BACKUP_DIR
# Set BACKUP_RETENTION_DAYS=0 to disable
# POSIX sh compatible for cron
#

SCRIPT_NAME="rotate-backups.sh"
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"

if [ "$RETENTION_DAYS" -le 0 ] 2>/dev/null; then
  echo "$SCRIPT_NAME: Rotation disabled (BACKUP_RETENTION_DAYS=$RETENTION_DAYS)" >&2
  exit 0
fi

if [ ! -d "$BACKUP_DIR" ]; then
  echo "$SCRIPT_NAME: Backup directory not found: $BACKUP_DIR" >&2
  exit 0
fi

find "$BACKUP_DIR" -type f \( -name "*.sql" -o -name "*.tar.gz" \) -mtime "+${RETENTION_DAYS}" -delete 2>/dev/null
echo "$SCRIPT_NAME: Pruned files older than $RETENTION_DAYS days" >&2
exit 0
