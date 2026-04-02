#!/bin/sh
#
# backup-configs.sh - Backup project config/ directory
# Backs up config/home, config/pi_home, config/pi_assets (bind mounts)
# POSIX sh compatible for cron
#

SCRIPT_NAME="backup-configs.sh"
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups}"
ERROR_FILE="${COTHROM_BACKUP_ERROR_FILE:-$HOME/.cothrom-backup-errors}"
DATE=$(date +%Y%m%d-%H%M%S)

# Project root: directory containing this script, one level up from scripts/
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
CONFIG_DIR="$PROJECT_ROOT/config"

log_error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $SCRIPT_NAME: $1" >> "$ERROR_FILE"
  echo "$SCRIPT_NAME: ERROR: $1" >&2
}

mkdir -p "$BACKUP_DIR/config"
OUTPUT_FILE="$BACKUP_DIR/config/config_${DATE}.tar.gz"

if [ ! -d "$CONFIG_DIR" ]; then
  log_error "config directory not found: $CONFIG_DIR"
  exit 1
fi

if tar czf "$OUTPUT_FILE" -C "$PROJECT_ROOT" config 2>/dev/null; then
  if [ -s "$OUTPUT_FILE" ]; then
    echo "$SCRIPT_NAME: OK config -> $OUTPUT_FILE" >&2
    exit 0
  else
    log_error "config backup produced empty file"
    rm -f "$OUTPUT_FILE"
    exit 1
  fi
else
  log_error "config backup failed - tar exited with error"
  rm -f "$OUTPUT_FILE"
  exit 1
fi
