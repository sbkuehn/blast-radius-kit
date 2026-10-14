#!/usr/bin/env bash
# az-zone-mapping.sh
# Shows how a subscription's logical zones (1, 2, 3) map to physical zones in
# a region. Pass a second subscription to compare: "zone 1" is a label, not a
# place.
#
# Usage:
#   ./az-zone-mapping.sh <region> [subscription-id] [second-subscription-id]
#   ./az-zone-mapping.sh eastus2
#   ./az-zone-mapping.sh eastus2 <sub-a> <sub-b>
#
# Read-only. Requires the Azure CLI (az) and an active `az login`.
# Docs: https://learn.microsoft.com/azure/reliability/availability-zones-overview

set -euo pipefail

usage() {
  echo "usage: $(basename "$0") <region> [subscription-id] [second-subscription-id]" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "error: $1 is not installed" >&2; exit 1; }
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" || -z "${1:-}" ]] && usage
require az

region="$1"
sub_a="${2:-$(az account show --query id -o tsv)}"
sub_b="${3:-}"

show_mapping() {
  echo "Subscription: $1"
  az rest --method get \
    --uri "/subscriptions/$1/locations?api-version=2022-12-01" \
    --query "value[?name=='${region}'].availabilityZoneMappings[] | sort_by(@, &logicalZone)" \
    -o table
  echo
}

show_mapping "$sub_a"

if [[ -n "$sub_b" ]]; then
  show_mapping "$sub_b"
  echo "Matching physicalZone values mean the same building, whatever the logical number says."
fi
