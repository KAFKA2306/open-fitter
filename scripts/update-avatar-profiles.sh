#!/usr/bin/env bash
# Fetch one or more tabs from the public MochiFitter profile Google Sheet.
# Usage examples:
#   ./scripts/update-avatar-profiles.sh                       # downloads default tabs
#   ./scripts/update-avatar-profiles.sh official:0 volunteer:<gid>
# Each argument is "name:gid" and will be saved as docs/data/avatar-<name>.csv.

set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="${ROOT_DIR}/docs/data"
mkdir -p "${DATA_DIR}"

BASE_URL="https://docs.google.com/spreadsheets/d/1ZjmAnVn41eV_z-UqUQ4n8qjMc6d9fpQ0aTgS7_d0E3E/export?format=csv&gid="

# Default sheet(s): "公式" タブ (gid=0)
DEFAULT_SHEETS=("official:0")

# Allow overriding via command-line args.
if [[ "$#" -gt 0 ]]; then
  SHEETS=("$@")
else
  SHEETS=("${DEFAULT_SHEETS[@]}")
fi

for entry in "${SHEETS[@]}"; do
  name="${entry%%:*}"
  gid="${entry#*:}"
  out="${DATA_DIR}/avatar-${name}.csv"
  echo "Downloading ${name} (gid=${gid}) -> ${out}"
  curl -L "${BASE_URL}${gid}" -o "${out}"
done

echo "All sheets downloaded."
