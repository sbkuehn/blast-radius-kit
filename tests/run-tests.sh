#!/usr/bin/env bash
# run-tests.sh
# Static checks for the whole repo. Nothing here deploys or touches a cloud
# account.
#
# Usage:
#   ./tests/run-tests.sh
#   SKIP_VALIDATE=1 ./tests/run-tests.sh   # skip terraform validate (offline)
#   TF_BIN=tofu ./tests/run-tests.sh       # use OpenTofu instead of Terraform
#
# Checks:
#   - every script in 01-explore/ follows the repo's script conventions
#   - shellcheck on every script
#   - every Terraform folder has the standard five files
#   - terraform fmt -check and terraform validate on every Terraform folder
#
# Missing tools are reported as skipped, not failed.

set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root" || exit 1

tf_bin="${TF_BIN:-terraform}"
tf_files=(versions.tf variables.tf main.tf outputs.tf terraform.tfvars.example)
pass=0
fail=0
skip=0

ok()  { echo "  PASS  $1"; pass=$((pass + 1)); }
bad() { echo "  FAIL  $1"; fail=$((fail + 1)); }
skp() { echo "  SKIP  $1"; skip=$((skip + 1)); }

scripts=()
while IFS= read -r -d '' f; do scripts+=("$f"); done < <(find 01-explore tests -name '*.sh' -print0 | sort -z)

tf_dirs=()
while IFS= read -r -d '' f; do tf_dirs+=("$(dirname "$f")"); done < <(find 0[2-9]-* -name main.tf -not -path '*/.terraform/*' -print0 | sort -z)

echo "== script conventions"
for s in "${scripts[@]}"; do
  [[ "$s" == tests/* ]] && continue
  missing=()
  head -1 "$s" | grep -q '^#!/usr/bin/env bash$' || missing+=("shebang")
  grep -q '^set -euo pipefail$' "$s" || missing+=("set -euo pipefail")
  grep -q '^usage() {' "$s" || missing+=("usage()")
  grep -q '^require() {' "$s" || missing+=("require()")
  grep -q '^# Usage:' "$s" || missing+=("Usage header")
  grep -q '^# Docs: ' "$s" || missing+=("Docs header")
  [[ -x "$s" ]] || missing+=("executable bit")
  if [[ ${#missing[@]} -eq 0 ]]; then ok "$s"; else bad "$s (missing: ${missing[*]})"; fi
done

echo "== shellcheck"
if command -v shellcheck >/dev/null 2>&1; then
  for s in "${scripts[@]}"; do
    if shellcheck "$s"; then ok "$s"; else bad "$s"; fi
  done
else
  skp "shellcheck not installed"
fi

echo "== terraform folder layout"
for d in "${tf_dirs[@]}"; do
  missing=()
  for f in "${tf_files[@]}"; do [[ -f "$d/$f" ]] || missing+=("$f"); done
  extra=$(find "$d" -maxdepth 1 -type f -name '*.tf' ! -name versions.tf ! -name variables.tf ! -name main.tf ! -name outputs.tf -printf '%f ')
  [[ -n "$extra" ]] && missing+=("unexpected: $extra")
  grep -q '^variable "region"' "$d/variables.tf" || missing+=("region variable")
  grep -q '^variable "prefix"' "$d/variables.tf" || missing+=("prefix variable")
  grep -q '^output "check_placement"' "$d/outputs.tf" || missing+=("check_placement output")
  if [[ ${#missing[@]} -eq 0 ]]; then ok "$d"; else bad "$d (${missing[*]})"; fi
done

echo "== $tf_bin fmt + validate"
if command -v "$tf_bin" >/dev/null 2>&1; then
  for d in "${tf_dirs[@]}"; do
    if "$tf_bin" -chdir="$d" fmt -check -diff >/dev/null; then ok "fmt $d"; else bad "fmt $d"; fi

    if [[ -n "${SKIP_VALIDATE:-}" ]]; then
      skp "validate $d (SKIP_VALIDATE set)"
      continue
    fi

    if "$tf_bin" -chdir="$d" init -backend=false -input=false >/dev/null 2>&1; then
      if "$tf_bin" -chdir="$d" validate -no-color >/dev/null; then ok "validate $d"; else bad "validate $d"; fi
    else
      skp "validate $d (init failed: no provider download?)"
    fi
  done
else
  skp "$tf_bin not installed"
fi

echo
echo "passed: $pass  failed: $fail  skipped: $skip"
[[ $fail -eq 0 ]]
