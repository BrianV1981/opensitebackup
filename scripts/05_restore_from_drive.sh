#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OSB_HOME="${OSB_HOME:-$(cd "$SCRIPT_DIR/.." && pwd)}"
ENV_FILE="${OSB_CONFIG:-$OSB_HOME/config/env.sh}"
source "$ENV_FILE"

: "${DRIVE_ACCOUNT:?DRIVE_ACCOUNT is required}"
: "${DRIVE_DB_FILE_ID:?DRIVE_DB_FILE_ID is required}"
: "${DRIVE_FILES_FILE_ID:?DRIVE_FILES_FILE_ID is required}"

SITE_PATH="${LOCAL_RESTORE_PATH:-$OSB_HOME/data/sites/tbsoftwash.com}"
TMP_DIR="${OSB_TMP:-$OSB_HOME/data/tmp}/restore-from-drive"
mkdir -p "$TMP_DIR"

DB_LOCAL="$TMP_DIR/live_db.sql"
FILES_LOCAL="$TMP_DIR/live_files.tar.gz"

echo "[1/6] Download DB from Drive..."
gog drive download "$DRIVE_DB_FILE_ID" --account "$DRIVE_ACCOUNT" --out "$DB_LOCAL" --no-input

echo "[2/6] Download files archive from Drive..."
gog drive download "$DRIVE_FILES_FILE_ID" --account "$DRIVE_ACCOUNT" --out "$FILES_LOCAL" --no-input

echo "[3/6] Prepare target path: $SITE_PATH"
mkdir -p "$SITE_PATH"
find "$SITE_PATH" -mindepth 1 -maxdepth 1 -exec rm -rf {} +

echo "[4/6] Extract files..."
tar -xzf "$FILES_LOCAL" -C "$SITE_PATH"

cd "$SITE_PATH"

echo "[5/6] Repoint wp-config to local DB credentials"
sed -i "s/define( 'DB_NAME'.*/define( 'DB_NAME', 'tbsoftwash_wp' );/" wp-config.php
sed -i "s/define( 'DB_USER'.*/define( 'DB_USER', 'tbsoftwash_user' );/" wp-config.php
sed -i "s/define( 'DB_PASSWORD'.*/define( 'DB_PASSWORD', 'ChangeThisNow_123!' );/" wp-config.php
sed -i "s/define( 'DB_HOST'.*/define( 'DB_HOST', 'localhost' );/" wp-config.php

echo "[6/6] Import DB and rewrite URL"
wp db import "$DB_LOCAL"
wp search-replace 'https://tbsoftwash.com' 'http://localhost:8081' --skip-columns=guid || true
wp search-replace 'http://tbsoftwash.com' 'http://localhost:8081' --skip-columns=guid || true
wp cache flush || true

echo "Restore complete."
echo "siteurl=$(wp option get siteurl)"
echo "blogname=$(wp option get blogname)"
