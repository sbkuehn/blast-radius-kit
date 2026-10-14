#!/usr/bin/env bash
# az-fault-domains.sh
# Shows how many fault domains an Azure region offers for availability sets.
# Some regions give you 3, some only 2.
#
# Usage:
#   ./az-fault-domains.sh <region>
#   ./az-fault-domains.sh westus
#
# Read-only. Requires the Azure CLI (az) and an active `az login`.
# Docs: https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview

set -euo pipefail

usage() {
  echo "usage: $(basename "$0") <region>" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "error: $1 is not installed" >&2; exit 1; }
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" || -z "${1:-}" ]] && usage
require az

region="$1"

# The backticks are JMESPath literals, not shell expansion, so single quotes are intentional.
# shellcheck disable=SC2016
query='[?name==`Aligned`].{Region:locationInfo[0].location, MaxFaultDomains:capabilities[0].value}'

az vm list-skus --resource-type availabilitySets --location "$region" \
  --query "$query" -o table
