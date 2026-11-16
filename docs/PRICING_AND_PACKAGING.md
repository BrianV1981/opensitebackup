# OpenSiteBackup Pricing & Packaging (Adoption-First)

## Strategy in one sentence
Keep the **core recovery workflow free and easy**, then monetize automation, scale, and team operations.

---

## Product promise (free tier)
The free version should feel usable by a non-technical owner:
- 1-click install
- guided setup
- 1-click first-run bootstrap flow
- 1-click backup
- 1-click local restore test
- clear pass/fail recovery checks

If the free experience is painful, adoption drops and paid conversion never compounds.

---

## Tier model

## Free (OSS / self-hosted)
Who it is for:
- single-site owners
- freelancers validating one-off recovery
- technical users evaluating trust

Includes:
- 1-click install path
- setup wizard (source + destination + first run)
- Backup now (manual)
- Verify backup integrity
- Restore to local test environment (1-click)
- Basic run history/log visibility
- Community documentation/support

Purpose:
- maximize trust and adoption
- prove restore confidence quickly

---

## Pro (paid add-on)
Who it is for:
- solo consultants
- freelancers managing multiple client sites

Includes everything in Free, plus:
- scheduled backups
- retention policies
- notification/alerts (email/Discord/etc.)
- improved retry/resume behavior
- cloud connector UX via OAuth (starting with Google Drive)
- basic reporting

Indicative pricing:
- per-site monthly price (example range: $10-$25/site/month)

---

## Agency
Who it is for:
- small/mid agencies operating many sites

Includes everything in Pro, plus:
- multi-site dashboard
- site grouping and policy templates
- role-based access controls
- activity/audit history
- monthly recovery confidence reporting

Indicative pricing:
- tiered bundles by site count

---

## Enterprise
Who it is for:
- larger teams with compliance/SLA needs

Includes everything in Agency, plus:
- advanced RBAC / SSO (future)
- compliance/report exports
- API + webhooks
- SLA and priority support
- onboarding/implementation services

Pricing:
- custom contract / annual terms

---

## What stays free forever
- core backup engine
- core restore workflow
- base adapters
- local restore drill capability
- basic docs

## What is paid
- orchestration convenience
- automation at scale
- multi-user/team controls
- advanced compliance and managed operations

---

## MVP UX requirements for adoption
Before heavy paid expansion, free UX should satisfy:
1. User can install without manual dependency debugging
2. First successful backup in under 10 minutes (typical path)
3. First successful local restore test in one guided flow
4. User sees explicit “recovery confidence” status

---

## Near-term implementation sequence
1. Free UX hardening
   - installer + setup wizard polish
   - one-click backup/restore test actions
   - recovery confidence status command
   - non-interactive default scaffold mode for first-run setup
2. Pro foundation
   - scheduler + retention + notifications
3. Connector layer
   - OAuth token vault + Google Drive connector
4. Scale layer
   - multi-site dashboard + team permissions
