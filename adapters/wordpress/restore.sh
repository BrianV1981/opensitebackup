#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

: "${LOCAL_BACKUP_ROOT:=${OSB_BACKUPS:-$OSB_HOME/data/backups/tbsoftwash-live}}"
MODE="${1:-local}"

wp_cmd() {
  WP_CLI_PHP_ARGS="${WP_CLI_PHP_ARGS:-} -d error_reporting=E_ERROR -d display_errors=0" \
    wp --skip-plugins --skip-themes "$@"
}

repoint_wp_config_from_env() {
  : "${LOCAL_DB_NAME:?LOCAL_DB_NAME is required for drive restore wp-config rewrite}"
  : "${LOCAL_DB_USER:?LOCAL_DB_USER is required for drive restore wp-config rewrite}"
  : "${LOCAL_DB_PASSWORD:?LOCAL_DB_PASSWORD is required for drive restore wp-config rewrite}"
  : "${LOCAL_DB_HOST:=localhost}"

  sed -i "s/define( 'DB_NAME'.*/define( 'DB_NAME', '${LOCAL_DB_NAME}' );/" wp-config.php
  sed -i "s/define( 'DB_USER'.*/define( 'DB_USER', '${LOCAL_DB_USER}' );/" wp-config.php
  sed -i "s/define( 'DB_PASSWORD'.*/define( 'DB_PASSWORD', '${LOCAL_DB_PASSWORD}' );/" wp-config.php
  sed -i "s/define( 'DB_HOST'.*/define( 'DB_HOST', '${LOCAL_DB_HOST}' );/" wp-config.php
}

restore_from_local() {
  : "${LOCAL_RESTORE_PATH:?LOCAL_RESTORE_PATH is required}"
  : "${LOCAL_URL:?LOCAL_URL is required}"

  local latest files_tar db_sql
  latest="$(ls -1dt "$LOCAL_BACKUP_ROOT"/* | head -n1)"
  files_tar="$(ls -1 "$latest"/*_files.tar.gz | head -n1)"
  db_sql="$(ls -1 "$latest"/*_db.sql | head -n1)"

  [[ -f "$files_tar" ]] || { echo "Missing files archive: $files_tar"; exit 70; }
  [[ -f "$db_sql" ]] || { echo "Missing db dump: $db_sql"; exit 70; }

  echo "About to restore into: $LOCAL_RESTORE_PATH"
  read -rp "Type YES to continue: " CONFIRM
  [[ "$CONFIRM" == "YES" ]] || exit 1

  mkdir -p "$LOCAL_RESTORE_PATH"
  find "$LOCAL_RESTORE_PATH" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

  tar -xzf "$files_tar" -C "$LOCAL_RESTORE_PATH"
  [[ -f "$LOCAL_RESTORE_PATH/wp-config.php" ]] || { echo "Restore failed: wp-config.php missing after extract"; exit 70; }

  cd "$LOCAL_RESTORE_PATH"
  wp_cmd db import "$db_sql"
  wp_cmd search-replace 'https://tbsoftwash.com' "$LOCAL_URL" --skip-columns=guid || true
  wp_cmd cache flush || true
}

restore_from_drive() {
  : "${DRIVE_ACCOUNT:?DRIVE_ACCOUNT is required}"
  : "${DRIVE_DB_FILE_ID:?DRIVE_DB_FILE_ID is required}"
  : "${DRIVE_FILES_FILE_ID:?DRIVE_FILES_FILE_ID is required}"

  local site_path tmp_dir db_local files_local
  site_path="${LOCAL_RESTORE_PATH:-$OSB_HOME/data/sites/tbsoftwash.com}"
  tmp_dir="${OSB_TMP:-$OSB_HOME/data/tmp}/restore-from-drive"
  mkdir -p "$tmp_dir"

  db_local="$tmp_dir/live_db.sql"
  files_local="$tmp_dir/live_files.tar.gz"

  echo "[1/6] Download DB from Drive..."
  gog drive download "$DRIVE_DB_FILE_ID" --account "$DRIVE_ACCOUNT" --out "$db_local" --no-input

  echo "[2/6] Download files archive from Drive..."
  gog drive download "$DRIVE_FILES_FILE_ID" --account "$DRIVE_ACCOUNT" --out "$files_local" --no-input

  [[ -f "$db_local" ]] || { echo "Missing downloaded DB: $db_local"; exit 70; }
  [[ -f "$files_local" ]] || { echo "Missing downloaded archive: $files_local"; exit 70; }

  echo "[3/6] Prepare target path: $site_path"
  mkdir -p "$site_path"
  find "$site_path" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

  echo "[4/6] Extract files..."
  tar -xzf "$files_local" -C "$site_path"
  [[ -f "$site_path/wp-config.php" ]] || { echo "Restore failed: wp-config.php missing after extract"; exit 70; }

  cd "$site_path"

  echo "[5/6] Repoint wp-config to local DB credentials from env"
  repoint_wp_config_from_env

  echo "[6/6] Import DB and rewrite URL"
  wp_cmd db import "$db_local"
  wp_cmd search-replace 'https://tbsoftwash.com' "$LOCAL_URL" --skip-columns=guid || true
  wp_cmd search-replace 'http://tbsoftwash.com' "$LOCAL_URL" --skip-columns=guid || true
  wp_cmd cache flush || true
}

post_restore_summary() {
  local siteurl blogname pages
  siteurl="$(wp_cmd option get siteurl)"
  blogname="$(wp_cmd option get blogname)"
  pages="$(wp_cmd post list --post_type=page --format=count)"
  echo "siteurl=$siteurl"
  echo "blogname=$blogname"
  echo "RESTORE_SUMMARY siteurl=$siteurl blogname=$(printf '%q' "$blogname") pages=$pages"
}

case "$MODE" in
  local)
    restore_from_local
    cd "$LOCAL_RESTORE_PATH"
    post_restore_summary
    ;;
  drive)
    restore_from_drive
    cd "${LOCAL_RESTORE_PATH:-$OSB_HOME/data/sites/tbsoftwash.com}"
    post_restore_summary
    ;;
  *)
    echo "Unknown restore mode: $MODE (expected: local|drive)" >&2
    exit 10
    ;;
esac

echo "Restore complete."
