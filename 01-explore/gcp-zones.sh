#!/usr/bin/env bash
# gcp-zones.sh
# Shows the zones in a Google Cloud region and their status.
#
# Usage:
#   ./gcp-zones.sh <region>
#   ./gcp-zones.sh us-central1
#
# Read-only. Requires the gcloud CLI with a project set.
# Docs: https://docs.cloud.google.com/compute/docs/regions-zones

set -euo pipefail

usage() {
  echo "usage: $(basename "$0") <region>" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "error: $1 is not installed" >&2; exit 1; }
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" || -z "${1:-}" ]] && usage
require gcloud

region="$1"

gcloud compute zones list \
  --filter="region:${region}" \
  --format="table(name, status, region.basename())"
