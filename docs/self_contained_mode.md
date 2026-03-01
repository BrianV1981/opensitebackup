# OpenSiteBackup — Self-Contained Mode

## Why
Many tools scatter files across the system. OpenSiteBackup supports a **single-root** layout so everything stays inside the project folder unless explicitly overridden.

## Core concept
Set one environment variable:

```bash
export OSB_HOME="/absolute/path/to/opensitebackup"
```

All default paths resolve from `OSB_HOME`.

## Default directory layout

```text
$OSB_HOME/
  bin/
  scripts/
  config/
    env.sh
  docs/
  data/
    backups/
    logs/
    tmp/
    state/
```

## Default path mapping
- `OSB_CONFIG`  -> `$OSB_HOME/config/env.sh`
- `OSB_BACKUPS` -> `$OSB_HOME/data/backups`
- `OSB_LOGS`    -> `$OSB_HOME/data/logs`
- `OSB_TMP`     -> `$OSB_HOME/data/tmp`
- `OSB_STATE`   -> `$OSB_HOME/data/state`

## Policy
1. Do not write outside `OSB_HOME` by default.
2. External write targets must be explicit (e.g., `LOCAL_RESTORE_PATH`).
3. No secrets committed to git.
4. No backup artifacts committed to git.

## External targets (allowed)
- Source host over SSH
- Cloud storage backend destinations
- Optional local restore target outside OSB_HOME

## Example
```bash
export OSB_HOME="$HOME/.openclaw/workspace/opensitebackup"
source "$OSB_HOME/config/env.sh"
```
