#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

: "${SOURCE_SITE_SLUG:=site}"
: "${LOCAL_BACKUP_ROOT:=${OSB_BACKUPS:-$OSB_HOME/data/backups/${SOURCE_SITE_SLUG}-live}}"
: "${OSB_RESTORE_CONFIRM_REQUIRED:=1}"
MODE="${1:-local}"

wp_cmd() {
  WP_CLI_PHP_ARGS="${WP_CLI_PHP_ARGS:-} -d error_reporting=E_ERROR -d display_errors=0" \
    wp --skip-plugins --skip-themes "$@"
}

repoint_wp_config_from_env() {
  : "${LOCAL_DB_NAME:?LOCAL_DB_NAME is required for restore wp-config rewrite}"
  : "${LOCAL_DB_USER:?LOCAL_DB_USER is required for restore wp-config rewrite}"
  : "${LOCAL_DB_PASSWORD:?LOCAL_DB_PASSWORD is required for restore wp-config rewrite}"
  : "${LOCAL_DB_HOST:=localhost}"

  sed -i "s/define( 'DB_NAME'.*/define( 'DB_NAME', '${LOCAL_DB_NAME}' );/" wp-config.php
  sed -i "s/define( 'DB_USER'.*/define( 'DB_USER', '${LOCAL_DB_USER}' );/" wp-config.php
  sed -i "s/define( 'DB_PASSWORD'.*/define( 'DB_PASSWORD', '${LOCAL_DB_PASSWORD}' );/" wp-config.php
  sed -i "s/define( 'DB_HOST'.*/define( 'DB_HOST', '${LOCAL_DB_HOST}' );/" wp-config.php
}

apply_rewrites() {
  if [[ -n "${OSB_REWRITE_FROM_1:-}" && -n "${OSB_REWRITE_TO_1:-}" ]]; then
    for i in 1 2 3 4 5; do
      local from_var="OSB_REWRITE_FROM_${i}" to_var="OSB_REWRITE_TO_${i}"
      local from_val="${!from_var:-}" to_val="${!to_var:-}"
      [[ -n "$from_val" && -n "$to_val" ]] || continue
      wp_cmd search-replace "$from_val" "$to_val" --skip-columns=guid || true
    done
  fi
}

validate_staged_restore() {
  wp_cmd core is-installed >/dev/null
  local siteurl blogname pages
  siteurl="$(wp_cmd option get siteurl 2>/dev/null || true)"
  blogname="$(wp_cmd option get blogname 2>/dev/null || true)"
  pages="$(wp_cmd post list --post_type=page --format=count 2>/dev/null || echo 0)"
  [[ -n "$siteurl" ]] || { echo "Validation failed: empty siteurl"; return 1; }
  [[ -n "$blogname" ]] || { echo "Validation failed: empty blogname"; return 1; }
  [[ "$pages" =~ ^[0-9]+$ ]] || pages=0
  (( pages > 0 )) || { echo "Validation failed: page count is 0"; return 1; }
}

atomic_restore_apply() {
  local files_tar="$1" db_sql="$2" site_path="$3"
  local ts stage_path backup_path state_dir db_rollback
  ts="$(date +%Y%m%d_%H%M%S)"
  state_dir="${OSB_STATE:-$OSB_HOME/data/state}"
  stage_path="${site_path}.staging.${ts}"
  backup_path="${site_path}.prev.${ts}"
  db_rollback="$state_dir/restore-db-rollback-${SOURCE_SITE_SLUG}-${ts}.sql"

  mkdir -p "$state_dir"
  mkdir -p "$stage_path"

  echo "[restore] staging extract -> $stage_path"
  tar -xzf "$files_tar" -C "$stage_path"
  [[ -f "$stage_path/wp-config.php" ]] || { echo "Restore failed: wp-config.php missing in staging"; return 1; }

  cd "$stage_path"
  repoint_wp_config_from_env

  echo "[restore] db rollback snapshot -> $db_rollback"
  wp_cmd db export "$db_rollback" >/dev/null 2>&1 || true

  echo "[restore] import staged db"
  if ! wp_cmd db import "$db_sql"; then
    echo "Restore failed during DB import"
    [[ -f "$db_rollback" ]] && wp_cmd db import "$db_rollback" >/dev/null 2>&1 || true
    return 1
  fi

  apply_rewrites
  wp_cmd cache flush || true

  echo "[restore] validate staged site"
  if ! validate_staged_restore; then
    echo "Restore validation failed; attempting DB rollback"
    [[ -f "$db_rollback" ]] && wp_cmd db import "$db_rollback" >/dev/null 2>&1 || true
    return 1
  fi

  echo "[restore] atomic filesystem swap"
  if [[ -d "$site_path" ]]; then
    mv "$site_path" "$backup_path"
  fi
  mv "$stage_path" "$site_path"

  echo "[restore] swap complete backup_path=$backup_path"
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

  if [[ "$OSB_RESTORE_CONFIRM_REQUIRED" == "1" ]]; then
    echo "About to staged-restore into: $LOCAL_RESTORE_PATH"
    read -rp "Type YES to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || exit 1
  fi

  atomic_restore_apply "$files_tar" "$db_sql" "$LOCAL_RESTORE_PATH"
}

restore_from_drive() {
  : "${DRIVE_ACCOUNT:?DRIVE_ACCOUNT is required}"
  : "${DRIVE_DB_FILE_ID:?DRIVE_DB_FILE_ID is required}"
  : "${DRIVE_FILES_FILE_ID:?DRIVE_FILES_FILE_ID is required}"

  local site_path tmp_dir db_local files_local
  site_path="${LOCAL_RESTORE_PATH:-$OSB_HOME/data/sites/${SOURCE_SITE_SLUG}}"
  tmp_dir="${OSB_TMP:-$OSB_HOME/data/tmp}/restore-from-drive"
  mkdir -p "$tmp_dir"

  db_local="$tmp_dir/live_db.sql"
  files_local="$tmp_dir/live_files.tar.gz"

  echo "[1/4] Download DB from Drive..."
  gog drive download "$DRIVE_DB_FILE_ID" --account "$DRIVE_ACCOUNT" --out "$db_local" --no-input
  echo "[2/4] Download files archive from Drive..."
  gog drive download "$DRIVE_FILES_FILE_ID" --account "$DRIVE_ACCOUNT" --out "$files_local" --no-input
  [[ -f "$db_local" ]] || { echo "Missing downloaded DB: $db_local"; exit 70; }
  [[ -f "$files_local" ]] || { echo "Missing downloaded archive: $files_local"; exit 70; }

  if [[ "$OSB_RESTORE_CONFIRM_REQUIRED" == "1" ]]; then
    echo "About to staged-restore (drive) into: $site_path"
    read -rp "Type YES to continue: " CONFIRM
    [[ "$CONFIRM" == "YES" ]] || exit 1
  fi

  echo "[3/4] Execute staged restore"
  atomic_restore_apply "$files_local" "$db_local" "$site_path"
  echo "[4/4] Done"
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
    cd "${LOCAL_RESTORE_PATH:-$OSB_HOME/data/sites/${SOURCE_SITE_SLUG}}"
    post_restore_summary
    ;;
  *)
    echo "Unknown restore mode: $MODE (expected: local|drive)" >&2
    exit 10
    ;;
esac

echo "Restore complete."
