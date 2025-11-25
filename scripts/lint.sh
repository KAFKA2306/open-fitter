#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

# Require pyflakes so CI and local runs behave the same.
if ! python3 - <<'PY'
import sys
try:
    import pyflakes  # noqa: F401
except ImportError:
    sys.exit(1)
PY
then
  echo "pyflakes is not installed. Run: python3 -m pip install -r requirements-dev.txt" >&2
  exit 1
fi

python3 -m pyflakes blender_addon/*.py
