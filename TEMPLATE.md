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

Measured on Railway (2026-11-24, idle after sign-in, a memo and an attachment):

| Service | Idle RAM | CPU idle |
|---|---|---|
| Memos | 0.08 GB | < 0.01 vCPU |
| Postgres | 0.07 GB | < 0.01 |

Total ≈ 0.15 GB → ≈ $1.5/month idle RAM plus the volume. Fits Trial and Free.

## Verification checklist

- [x] Both services SUCCESS, `/healthz` 200; log `applied configuration … changes="[create instance/settings/GENERAL create users/admin]"`; profile `needsSetup=false`.
- [x] Stranger `POST /api/users` → 403 "user registration is not allowed".
- [x] `admin` sign-in (role ADMIN); memo create; content filter finds it; attachment upload and download (local storage on the volume).
- [x] Redeploy with `MEMOS_ADMIN_PASSWORD=abc`: SUCCESS, warning logged, `configuration unchanged`, old password still works, attachment still served.
- [x] New 24-character password + `MEMOS_ADMIN_LOGIN_VERSION=2`: password re-applied (serial 2), login with the new password works.

## Open questions

- S3 storage via the declarative STORAGE setting was not used (it would lock the storage settings in the UI).
