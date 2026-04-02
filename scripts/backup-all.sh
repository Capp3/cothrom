#!/bin/sh
#
# backup-all.sh - Run all backup scripts: databases, configs, then rotation
# Wrapper for cron; aggregates errors to ERROR_FILE
# POSIX sh compatible for cron
#

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups}"
ERROR_FILE="${COTHROM_BACKUP_ERROR_FILE:-$HOME/.cothrom-backup-errors}"
RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-7}"
FAILED=0

export BACKUP_DIR
export COTHROM_BACKUP_ERROR_FILE="$ERROR_FILE"
export BACKUP_RETENTION_DAYS="$RETENTION_DAYS"

if ! "$SCRIPT_DIR/backup-databases.sh"; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] backup-all.sh: backup-databases.sh failed" >> "$ERROR_FILE"
  FAILED=1
fi

if ! "$SCRIPT_DIR/backup-configs.sh"; then
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] backup-all.sh: backup-configs.sh failed" >> "$ERROR_FILE"
  FAILED=1
fi

if [ "$RETENTION_DAYS" -gt 0 ] 2>/dev/null; then
  "$SCRIPT_DIR/rotate-backups.sh"
fi

exit $FAILED
