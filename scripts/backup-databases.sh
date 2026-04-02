#!/bin/sh
#
# backup-databases.sh - Backup all database containers with io.cothrom labels
# Uses Docker labels: io.cothrom.role=database, io.cothrom.data=true, io.cothrom.db.backup.command
# POSIX sh compatible for cron
#

SCRIPT_NAME="backup-databases.sh"
BACKUP_DIR="${BACKUP_DIR:-$HOME/backups}"
ERROR_FILE="${COTHROM_BACKUP_ERROR_FILE:-$HOME/.cothrom-backup-errors}"
DATE=$(date +%Y%m%d-%H%M%S)
FAILED=0

log_error() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $SCRIPT_NAME: $1" >> "$ERROR_FILE"
  echo "$SCRIPT_NAME: ERROR: $1" >&2
}

# Find database containers: role=database, data=true
# Docker Compose stores label values with quotes (e.g. "database" not database)
CONTAINERS=$(docker ps -q --filter 'label=io.cothrom.role="database"' --filter 'label=io.cothrom.data="true"' 2>/dev/null)

if [ -z "$CONTAINERS" ]; then
  echo "$SCRIPT_NAME: No database containers found" >&2
  exit 0
fi

for CONTAINER_ID in $CONTAINERS; do
  BACKUP_CMD=$(docker inspect --format '{{index .Config.Labels "io.cothrom.db.backup.command"}}' "$CONTAINER_ID" 2>/dev/null)
  if [ -z "$BACKUP_CMD" ]; then
    continue
  fi
  # Strip surrounding double-quotes from label value (Docker Compose stores them)
  case "$BACKUP_CMD" in
    '"'*'"') BACKUP_CMD=$(echo "$BACKUP_CMD" | sed 's/^"//;s/"$//') ;;
  esac

  STACK=$(docker inspect --format '{{index .Config.Labels "io.cothrom.stack"}}' "$CONTAINER_ID" 2>/dev/null)
  case "$STACK" in '"'*'"') STACK=$(echo "$STACK" | sed 's/^"//;s/"$//') ;; esac
  CONTAINER_NAME=$(docker inspect --format '{{.Name}}' "$CONTAINER_ID" 2>/dev/null | sed 's|^/||')

  if [ -z "$STACK" ]; then
    STACK=$(echo "$CONTAINER_NAME" | sed 's/_.*//')
  fi

  STACK_DIR="$BACKUP_DIR/$STACK"
  mkdir -p "$STACK_DIR"
  OUTPUT_FILE="$STACK_DIR/${CONTAINER_NAME}_${DATE}.sql"

  EXEC_ERR=$(mktemp)

  if docker exec "$CONTAINER_ID" sh -c "$BACKUP_CMD" > "$OUTPUT_FILE" 2>"$EXEC_ERR"; then
    rm -f "$EXEC_ERR"
    if [ -s "$OUTPUT_FILE" ]; then
      echo "$SCRIPT_NAME: OK $CONTAINER_NAME -> $OUTPUT_FILE" >&2
    else
      log_error "$CONTAINER_NAME produced empty backup"
      rm -f "$OUTPUT_FILE"
      FAILED=1
    fi
  else
    ERR_MSG=$(cat "$EXEC_ERR" 2>/dev/null | head -3 | tr '\n' ' ')
    rm -f "$EXEC_ERR"
    log_error "$CONTAINER_NAME failed - $ERR_MSG"
    echo "$SCRIPT_NAME: $CONTAINER_NAME stderr: $ERR_MSG" >&2
    rm -f "$OUTPUT_FILE"
    FAILED=1
  fi
done

exit $FAILED
