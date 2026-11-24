# Memos for Railway: the official image pinned by digest plus a start script that
# writes Memos' declarative configuration (admin account, sign-up off) so the
# instance is never served without an administrator.
ARG MEMOS_IMAGE=neosmemo/memos:26.11.2@sha256:3c7bd779510403350465ecabb7e6fbc0887206f9d55b8decf51a205613fa5616
FROM ${MEMOS_IMAGE}

COPY --chmod=0755 railway-memos.sh /usr/local/memos/railway-memos.sh
ENTRYPOINT ["/usr/local/memos/railway-memos.sh"]
