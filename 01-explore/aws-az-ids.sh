#!/usr/bin/env bash
# aws-az-ids.sh
# Shows the Availability Zone names in your account next to their AZ IDs.
# Zone names (us-east-1a) can map to different physical zones per account;
# AZ IDs (use1-az1) are the same everywhere.
#
# Usage:
#   ./aws-az-ids.sh <region>
#   ./aws-az-ids.sh us-east-1
#
# Read-only. Requires the AWS CLI (aws) with credentials configured.
# Docs: https://docs.aws.amazon.com/global-infrastructure/latest/regions/az-ids.html

set -euo pipefail

usage() {
  echo "usage: $(basename "$0") <region>" >&2
  exit 1
}

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "error: $1 is not installed" >&2; exit 1; }
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" || -z "${1:-}" ]] && usage
require aws

region="$1"

aws ec2 describe-availability-zones --region "$region" \
  --filters Name=zone-type,Values=availability-zone \
  --query "AvailabilityZones[].{Name:ZoneName, ID:ZoneId, State:State}" \
  --output table
