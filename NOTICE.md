# Notice

This repository is a Railway template package for Memos. It contains a Dockerfile and a start script written for this template (MIT-licensed); it does not contain Memos source code.

| Component | License | Used as |
|---|---|---|
| Memos 26.11.2 | MIT (Copyright (c) 2022 Memos) | Official image `neosmemo/memos:26.11.2@sha256:3c7bd779…`, extended with our start script; the image's own entrypoint still drops privileges |
| PostgreSQL 18 | PostgreSQL License | `ghcr.io/railwayapp-templates/postgres-ssl:18.6` (Railway) |

## Our own code

- `services/memos/railway-memos.sh`: writes a Memos declarative configuration file (admin user, self-registration setting, lifecycle rules) and starts the image's entrypoint.

## Upstream files checked (tag 26.11.2)

- `scripts/Dockerfile`, `scripts/entrypoint.sh`, `cmd/memos/main.go`, `server/server.go`, `proto/api/user_service.proto`, `proto/api/auth_service.proto`, `proto/api/instance_service.proto`, `docs/design/declarative-configuration.md`, `core/configuration/plan.go`, `core/configuration/diff.go`

This community template is not affiliated with or endorsed by the Memos project.
