# OpenSiteBackup — Troubleshooting Matrix

| Stage | Symptom | Likely Cause | Action |
|---|---|---|---|
| Preflight | `MISSING: <binary>` | Dependency not installed | Install tool and rerun `preflight --strict` |
| Preflight | `MISSING ENV: ...` | Incomplete `config/env.sh` | Add required env vars for selected backend |
| Upload | Unknown backend | Invalid `OSB_BACKEND` value | Use `gog`, `local`, or `rclone` |
| Upload | Backend not executable | Script permission issue | `chmod +x backends/*/upload.sh` |
| Upload | Intermittent provider errors | Transient network/provider issue | Increase `OSB_UPLOAD_RETRIES` and rerun |
| Verify | Tar integrity failure | Corrupted/incomplete archive | Re-run backup pull and verify |
| Verify | SQL sanity check failure | Partial DB export | Re-run backup stage and inspect DB dump |
| Restore | Missing artifacts | Verify stage not complete | Run `scripts/02_verify_backup.sh` first |
| Restore | `wp-config.php` missing | Bad extraction/artifact | Rebuild/re-download artifacts |
| Restore | URL mismatch post-restore | search-replace not applied | Re-run restore and inspect `LOCAL_URL` |
| Restore | Non-fatal WP warnings | Plugin/theme bootstrap noise | Continue if summary checks pass; inspect logs if behavior broken |

## Success indicators

- `Integrity check passed: ...`
- `Local backend upload complete: ...` or cloud upload DONE markers
- `RESTORE_SUMMARY siteurl=... blogname=... pages=...`
- `PRE_RELEASE_CHECK: OK`
