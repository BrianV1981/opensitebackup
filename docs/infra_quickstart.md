# Infrastructure Quickstart

## 1) Initialize local config
```bash
cp config/env.example config/env.sh
# edit config/env.sh with your values
```

## 2) Preflight
```bash
bash scripts/preflight.sh --strict
```

## 3) Run pipeline
```bash
bash scripts/01_pull_live_backup.sh
bash scripts/02_verify_backup.sh
bash scripts/03_upload_to_drive.sh
```

## 4) Restore drill (optional)
```bash
bash scripts/04_restore_local.sh
```
