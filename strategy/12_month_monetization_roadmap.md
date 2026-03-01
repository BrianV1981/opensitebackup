# 12-Month Monetization Roadmap

## Goal
Build adoption with open-source reliability, then monetize operational convenience and multi-site management.

## Phase 1 (Months 0-2): OSS Foundation

### Build
- Stable WordPress backup/verify/restore flow
- Storage adapter interface (local, rclone, gog optional)
- Deterministic logs + checksums + manifests
- Restore-drill script and docs

### GTM
- Publish GitHub repo with clear DR-first positioning
- Dogfood with real site backups
- Gather 5-15 early users from agencies/freelancers

### Revenue
- Optional: paid setup/support calls

## Phase 2 (Months 3-5): Operator Pro Features (Open + Paid Add-ons)

### Build
- Scheduler + retention policies
- Multi-site config handling
- Better retry/resume and notifications
- Basic web dashboard (self-hosted)

### Monetization tests
- Paid "Pro Pack" for:
  - notifications
  - policy templates
  - advanced reporting
- Paid support subscription

### KPIs
- Weekly active installs
- Successful restore drill rate
- Time-to-recovery (TTR)

## Phase 3 (Months 6-8): Hosted SaaS Control Plane

### Build
- Hosted dashboard for multi-site orchestration
- Team accounts, RBAC, activity history
- Bring-your-own-storage + managed storage option

### Pricing draft
- Free OSS self-hosted
- Pro SaaS: $10-$25/site/mo
- Agency bundles: tiered by site count
- Enterprise: custom SLA

### Sales motion
- Start with agencies and niche operators
- Emphasize "restore confidence" and auditability

## Phase 4 (Months 9-12): Expansion + Enterprise Readiness

### Build
- Additional adapters (Ghost, static, custom app)
- Immutable snapshot options
- Compliance/reporting exports
- API + webhook ecosystem

### Monetization
- Managed storage upsell
- Incident response and migration services
- White-label agency portal

### KPI targets
- Net dollar retention > 100% in agency segment
- Churn < 3-5% monthly for paying customers
- 20-30% of active OSS users convert to paid services/tools over time

## What stays free forever
- Core backup engine
- Base adapters
- Restore CLI
- Basic docs

## What can be paid
- Hosted orchestration
- Team workflows/RBAC/audit
- Managed storage/compliance
- Premium adapters/integrations
- Priority support + implementation
