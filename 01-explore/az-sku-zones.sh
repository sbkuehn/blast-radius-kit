#!/usr/bin/env bash
# az-sku-zones.sh
# Shows which zones offer a VM size in a region, and any zone restrictions on
# your subscription. Run this before you design around "all three zones are
# open."
#
# Usage:
#   ./az-sku-zones.sh <region> <vm-size>
#   ./az-sku-zones.sh eastus2 Standard_D4s_v5
#
# Read-only. Requires the Azure CLI (az) and an active `az login`.
# Docs: https://learn.microsoft.com/en-us/cli/azure/vm#az-vm-list-skus

set -euo pipefail

usage() {
  echo "usage: $(basename "$0") <region> <vm-size>" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "error: $1 is not installed" >&2; exit 1; }
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" || -z "${1:-}" || -z "${2:-}" ]] && usage
require az

region="$1"
size="$2"

echo "Zones offering ${size} in ${region}:"
az vm list-skus --location "$region" --size "$size" --zone \
  --query "[?name=='${size}'].{Size:name, Zones:join(', ', locationInfo[0].zones)}" \
  -o table

echo
echo "Restrictions on your subscription (empty means none):"
az vm list-skus --location "$region" --size "$size" --all \
  --query "[?name=='${size}'].restrictions[].{Type:type, Reason:reasonCode, Zones:join(', ', restrictionInfo.zones || \`[]\`)}" \
  -o table
