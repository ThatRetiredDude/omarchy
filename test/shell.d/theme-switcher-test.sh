#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

stub_bin="$tmp/bin"
stock="$tmp/omarchy/themes"
user="$tmp/home/.config/omarchy/themes"
mkdir -p "$stub_bin" "$stock/white" "$user/aurora/backgrounds"

# The switcher hands its preview directory to the picker, which lists only the
# previews that resolve to a file; list those instead.
cat >"$stub_bin/omarchy-menu-images" <<'EOF'
#!/bin/bash
for entry in "${@: -1}"/*; do
  [[ -f $entry ]] && printf '%s\n' "${entry##*/}"
done
exit 0
EOF
chmod +x "$stub_bin/omarchy-menu-images"

printf 'png' >"$stock/white/preview.png"
printf 'jpg' >"$user/aurora/backgrounds/1-forest.jpg"
touch -d '2026-01-01 00:00' "$user/aurora/backgrounds"

run_switcher() {
  HOME="$tmp/home" XDG_CACHE_HOME="$tmp/cache" OMARCHY_PATH="$tmp/omarchy" PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-theme-switcher"
}

entries=$(run_switcher)
grep -Fxq 'aurora.jpg' <<<"$entries" || fail "a theme without a preview file shows its first background" "$entries"

# A theme update that renames the background changes backgrounds/, not the theme folder.
mv "$user/aurora/backgrounds/1-forest.jpg" "$user/aurora/backgrounds/1-forest-4k.jpg"
entries=$(run_switcher)
grep -Fxq 'aurora.jpg' <<<"$entries" || fail "a theme stays listed after its first background is renamed" "$entries"
[[ $(readlink "$tmp/cache/omarchy/theme-selector/previews/aurora.jpg") == "$user/aurora/backgrounds/1-forest-4k.jpg" ]] ||
  fail "a theme's preview follows its renamed background"
pass "a theme without a preview file stays listed when its backgrounds change"
