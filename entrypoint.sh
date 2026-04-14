#!/usr/bin/env bash
set -euo pipefail

JUPYTER_PORT="${JUPYTER_PORT:-8888}"

if [[ -z "${JUPYTER_PASSWORD:-}" ]]; then
  echo "JUPYTER_PASSWORD is not set. Refusing to start without password auth." >&2
  exit 1
fi

PASSWORD_HASH="$(
python - <<'PY'
import os
from jupyter_server.auth import passwd

print(passwd(os.environ["JUPYTER_PASSWORD"]))
PY
)"

exec jupyter lab \
  --ip=0.0.0.0 \
  --port="${JUPYTER_PORT}" \
  --no-browser \
  --allow-root \
  --ServerApp.token='' \
  --ServerApp.password="${PASSWORD_HASH}" \
  --ServerApp.allow_remote_access=True \
  --ServerApp.root_dir=/workspace
