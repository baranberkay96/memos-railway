# Deploy and Host Memos with Railway

Memos is a lightweight, open-source note-taking service: write short Markdown notes in a timeline, tag them, attach files, and keep them private or share them. This template runs Memos 26.11 on PostgreSQL 18 with an administrator account created on the first start and public sign-up switched off.

## About Hosting Memos

Memos is a single Go binary. On a fresh instance the first visitor can create the administrator account, which is a race on a public URL. Memos 26 supports declarative configuration applied at startup, after the database migration and before the server answers requests. This template writes that configuration from your variables: an `admin` account with a generated password and self-registration turned off.

Notes and settings live in PostgreSQL. Attachments use Memos' default local storage on a Railway volume; you can switch to S3 storage in the settings.

## Common Use Cases

- Private journal and daily notes with tags and full-text search
- Quick capture of ideas, links and snippets from any device
- Small team or family microblog with shared and private memos
- Personal knowledge base written in Markdown
- Self-hosted replacement for note apps that keep your data on their servers

## Dependencies for Memos Hosting

- Memos 26.11.2 (official image, pinned by digest)
- PostgreSQL 18 (Railway's `postgres-ssl` image)
- A Railway volume for attachments

### Deployment Dependencies

- Memos source: https://github.com/usememos/memos
- Documentation: https://usememos.com/docs
- Declarative configuration design: https://github.com/usememos/memos/blob/main/docs/design/declarative-configuration.md

### Implementation Details

| Service | What it does | Public |
|---|---|---|
| Memos | Web app and API; applies the admin/sign-up configuration at startup | yes |
| Postgres | Notes, users and settings | no |

The Memos service mounts a volume at `/var/opt/memos` for attachments.

**First login**

1. Open the Memos URL and sign in as `admin` with the generated `MEMOS_ADMIN_PASSWORD` (Memos service, Variables tab).
2. Add people under Settings > Members, or set `MEMOS_ALLOW_REGISTRATION=true` and redeploy to let visitors sign up.

**Admin password.** Change it in your profile; the change survives restarts. To reset a forgotten password, set a new `MEMOS_ADMIN_PASSWORD` (12+ characters), raise `MEMOS_ADMIN_LOGIN_VERSION` by 1 and redeploy. A password under 12 characters is never applied; if it would be, the account is locked with a random password and the log explains the fix.

**Managed by configuration.** The `admin` account's user name and role and the self-registration switch are managed by the template's configuration file, so Memos shows them as read-only in the UI. Change self-registration with `MEMOS_ALLOW_REGISTRATION`. Everything else (branding, other users, storage, access mode) stays editable in Settings.

**Custom domain.** Add it to the Memos service, set `MEMOS_INSTANCE_URL` to `https://{your-domain}` and redeploy.

**Versions.** The image is pinned by digest in `services/memos/Dockerfile`. To upgrade, change the tag and digest, back up Postgres and redeploy; migrations run on start.

**Resources.** About 0.1 GB RAM idle in total (Memos ~0.05 GB, Postgres ~0.05 GB), roughly $1–2 per month plus volume storage. Runs on the Trial plan.

**License.** Memos is MIT-licensed. This is a community template, not affiliated with the Memos project.

### Why Deploy Memos on Railway?

Railway runs Memos and PostgreSQL in one project with HTTPS, private networking and a persistent volume. Your admin account exists before the site is reachable, nobody can sign up without your say, and upgrades are a one-line change.
