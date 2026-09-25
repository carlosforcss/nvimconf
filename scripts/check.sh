#!/bin/sh
# Smoke test for this Neovim config. Run after any change: scripts/check.sh
#   1. utils/symbols.lua over scripts/fixture (compare with scripts/fixture/expected.txt;
#      regenerate with: scripts/check.sh --update-symbols)
#   2. a real nvim session in a pseudo-terminal (headless nvim never fires VeryLazy):
#      colorscheme, every keymap in lua/config/keymaps.lua, <leader>ss in an LSP buffer, no startup errors
set -u
ROOT=$(cd "$(dirname "$0")/.." && pwd)
FIXTURE="$ROOT/scripts/fixture"
status=0

if [ "${1:-}" = "--update-symbols" ]; then
  exec nvim --headless -u NONE --cmd "set rtp^=$ROOT" -l "$ROOT/scripts/check_symbols.lua" "$FIXTURE" --update
fi

nvim --headless -u NONE --cmd "set rtp^=$ROOT" -l "$ROOT/scripts/check_symbols.lua" "$FIXTURE" || status=1

OUT=$(mktemp)
rm -f "$OUT"
NVIM_CMD="nvim -R -c 'luafile $ROOT/scripts/check_session.lua' '$ROOT/lua/utils/cheatsheet.lua'"
if [ "$(uname)" = "Darwin" ]; then
  CHECK_OUT="$OUT" script -q /dev/null sh -c "$NVIM_CMD" >/dev/null 2>&1 </dev/null &
else
  CHECK_OUT="$OUT" script -qec "$NVIM_CMD" /dev/null >/dev/null 2>&1 </dev/null &
fi
pid=$!

i=0
while [ ! -s "$OUT" ] && [ $i -lt 60 ]; do
  sleep 1
  i=$((i + 1))
done
# give nvim a moment to exit on its own, then make sure the pty is gone
i=0
while kill -0 "$pid" 2>/dev/null && [ $i -lt 5 ]; do
  sleep 1
  i=$((i + 1))
done
kill "$pid" 2>/dev/null
wait "$pid" 2>/dev/null

if [ -s "$OUT" ]; then
  cat "$OUT"
  grep -q '^FAIL' "$OUT" && status=1
else
  echo "FAIL session: nvim produced no results within 60s"
  status=1
fi
rm -f "$OUT"

[ $status -eq 0 ] && echo "All checks passed" || echo "Some checks FAILED"
exit $status
