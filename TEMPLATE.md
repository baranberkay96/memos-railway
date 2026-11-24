# Memos 26.11 Private Notes and Microblog (Postgres): composer spec

## Listing

| Field | Value |
|---|---|
| Name | **Memos 26.11 Private Notes and Microblog (Postgres)** |
| Description | Self-hosted note-taking and microblog; admin preset, sign-up closed. (68 chars) |
| Category | Other |
| Icon | `https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/memos.svg` |
| Repo | `baranberkay96/memos-railway`, root `/services/memos` |

Memos uses calendar versions since 26.10 (`26.11.2`).

## Base market templates (checked 2026-11-24)

| Code | Active | Notes |
|---|---|---|
| `RaK3xU` | 50 | `neosmemo/memos:stable` floating, `postgres:15` without Railway's SSL image; first visitor becomes admin |
| `memos` | 29 | `memos:stable`, Postgres 16, no healthcheck, first visitor becomes admin |
| `memos-2` | 21 | `memos:0.26.2` (old), SQLite on a volume |

## Services

| Service | Source | Port | Healthcheck | Volume |
|---|---|---|---|---|
| Memos | repo `/services/memos` (`FROM neosmemo/memos:26.11.2@sha256:3c7bd779…` + start script) | 5230 public | `/healthz` (600 s) | `/var/opt/memos` (attachments) |
| Postgres | `postgres-ssl:18.6` | 5432 private | — | `/var/lib/postgresql/data` |

## Design

1. **Admin before serving (8.37), the upstream way.** Memos 26 applies declarative configuration files at startup, after migration and before serving. The start script writes `/etc/memos/railway/railway.json`: user `users/admin` (role ADMIN, password `${env:…}`, `preventDestroy`, `writeOnlyVersion` from `MEMOS_ADMIN_LOGIN_VERSION`) and the GENERAL setting `disallowUserRegistration` from `MEMOS_ALLOW_REGISTRATION`, with every other GENERAL field in `ignoreChanges` so branding stays editable.
2. **Password is write-only:** applied on create and when `MEMOS_ADMIN_LOGIN_VERSION` rises, so a UI password change survives restarts. Under 12 characters it is replaced by a random one (logged).
3. **Fixed admin user name** `admin`: a configurable name would turn a later rename into a "managed resource missing" startup error.
4. Postgres for data; attachments use Memos' default local storage on the volume. The image entrypoint still fixes volume ownership and drops to UID 10001.

## Improvements over market templates

- No first-visitor admin, sign-up closed by default, pinned digest, healthcheck, Railway Postgres image on the private network.

## Resources

See the round-13 report for measured values.

## Verification checklist

- [ ] SUCCESS; `/healthz` 200; profile `needsSetup=false`.
- [ ] Stranger sign-up refused; admin sign-in; memo create + filter; attachment stored.

## Open questions

- S3 storage via the declarative STORAGE setting was not used (it would lock the storage settings in the UI).
