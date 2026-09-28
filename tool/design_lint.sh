#!/usr/bin/env bash
# Design system guardrail (docs/ui-ux-polish-plan.md §7).
#
# Flags raw design values in lib/ that should come from the tokens in
# lib/app/theme/. Reports by default; pass --strict to exit non-zero when
# anything is found (for CI once the screen migrations are done).
#
#   tool/design_lint.sh            # report
#   tool/design_lint.sh --strict   # fail on violations
set -uo pipefail

cd "$(dirname "$0")/.."

strict=false
[[ "${1:-}" == "--strict" ]] && strict=true

# Token definitions and generated code are allowed to hold raw values.
exclude=(--glob '!lib/app/theme/**' --glob '!lib/l10n/**' --glob '!**/*.g.dart'
  --glob '!lib/firebase_options.dart')

if command -v rg >/dev/null 2>&1; then
  search() { rg --line-number --no-heading "${exclude[@]}" -e "$1" lib; }
else
  search() {
    grep -rnE --include='*.dart' --exclude='*.g.dart' "$1" lib |
      grep -vE '^lib/(app/theme|l10n)/|^lib/firebase_options.dart'
  }
fi

total=0
check() {
  local name="$1" pattern="$2"
  local hits
  hits="$(search "$pattern" || true)"
  local count=0
  [[ -n "$hits" ]] && count="$(printf '%s\n' "$hits" | wc -l | tr -d ' ')"
  total=$((total + count))
  printf '%-44s %s\n' "$name" "$count"
  if [[ "$count" -gt 0 && "${VERBOSE:-}" == "1" ]]; then
    printf '%s\n' "$hits" | sed 's/^/    /'
  fi
}

echo "Design lint (VERBOSE=1 lists locations)"
echo "-------------------------------------------------------"
check "Raw colours: Color(0x...)" 'Color\(0x'
check "Raw colours: Color.fromRGBO / Colors.<x>" 'Color\.fromRGBO|Colors\.(red|green|blue|grey|amber|black|white)\b'
check "Literal font sizes (use AppTextStyles)" 'fontSize: *[0-9]'
check "Material icons (use AppIcons)" '\bIcons\.[a-z]'
check "Direct Iconsax imports (use AppIcons)" "package:iconsax_flutter"
check "GoogleFonts outside the theme" 'GoogleFonts\.'
check "Literal corner radii (use AppRadius)" 'circular\( *[0-9]'
check "Off-scale spacing literals" '(EdgeInsets\.[a-zA-Z]+\([^)]*\b(3|5|6|7|9|10|11|13|14|15|18|22|26|28|30|34|36|44)\b|SizedBox\((height|width): *(3|5|6|7|9|10|11|13|14|15|18|22|26|28|30|34|44)\b)'
echo "-------------------------------------------------------"
echo "Total: $total"

if $strict && [[ "$total" -gt 0 ]]; then
  exit 1
fi
