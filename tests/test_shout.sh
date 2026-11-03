#!/usr/bin/env bash
# Tests for shout CLI. One-command run: bash tests/test_shout.sh
# Resolves the CLI relative to this file so the suite is path-independent
# (works in a fresh clone at any location).
set -u
SHOUT="$(cd "$(dirname "$0")/.." && pwd)/shout"
PASS=0
FAIL=0

check() { # $1=name $2=expected $3=actual
  if [ "$2" = "$3" ]; then PASS=$((PASS+1)); echo "ok - $1";
  else FAIL=$((FAIL+1)); echo "FAIL - $1"; echo "  expected: $(printf %q "$2")"; echo "  actual:   $(printf %q "$3")"; fi
}
check_exit() { # $1=name $2=expected_exit $3=actual_exit
  if [ "$2" = "$3" ]; then PASS=$((PASS+1)); echo "ok - $1 (exit $3)";
  else FAIL=$((FAIL+1)); echo "FAIL - $1 (expected exit $2, got $3)"; fi
}

# 1. stdin uppercasing (preserves surrounding spaces + newline)
out=$(printf ' hi \n' | "$SHOUT"); check "stdin uppercases" " HI " "$out"

# 2. file-arg uppercasing
f=$(mktemp); printf 'hello\nworld\n' > "$f"
out=$("$SHOUT" "$f"); check "file-arg uppercases" "$(printf 'HELLO\nWORLD')" "$out"
rm -f "$f"

# 3. --trim strips then uppercases (stdin)
out=$(printf ' hi \n' | "$SHOUT" --trim); check "--trim stdin strips+upper" "HI" "$out"

# 3b. --trim with file arg
f=$(mktemp); printf '  abc  \n\tdef\t\n' > "$f"
out=$("$SHOUT" --trim "$f"); check "--trim file strips+upper" "$(printf 'ABC\nDEF')" "$out"
rm -f "$f"

# 4. unknown flag exits 2 + stderr
err=$(mktemp); out=$("$SHOUT" --bogus 2>"$err" >/dev/null); code=$?
check_exit "unknown flag exits 2" "2" "$code"
if grep -q "unknown flag" "$err"; then PASS=$((PASS+1)); echo "ok - unknown flag stderr"; else FAIL=$((FAIL+1)); echo "FAIL - unknown flag stderr missing"; cat "$err"; fi
rm -f "$err"

# 5. multi-file order (file args concatenated in order)
f1=$(mktemp); f2=$(mktemp); printf 'aaa\n' > "$f1"; printf 'bbb\n' > "$f2"
out=$("$SHOUT" "$f1" "$f2"); check "multi-file order" "$(printf 'AAA\nBBB')" "$out"
rm -f "$f1" "$f2"

# 6. byte-exact newline preservation (no trailing newline stays without one)
out=$(printf 'hi' | "$SHOUT" | od -An -c | tr -d ' \n'); check "no-trailing-newline preserved" "HI" "$(printf 'hi' | "$SHOUT")"

echo "---"
echo "$PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
