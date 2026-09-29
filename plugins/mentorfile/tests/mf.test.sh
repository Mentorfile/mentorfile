#!/usr/bin/env bash
# Offline checks for scripts/mf. Run: bash plugins/mentorfile/tests/mf.test.sh
set -uo pipefail
cd "$(dirname "$0")/.."
MF="$PWD/scripts/mf"
FIX="$PWD/evals/mine-fixtures/transcripts"
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
export HOME="$T/home" MENTORFILE_HOME="$T/home/.mentorfile"
mkdir -p "$HOME/.claude"
fails=0
check() { if eval "$2"; then echo "ok   $1"; else echo "FAIL $1"; fails=$((fails + 1)); fi; }

# extract: only the user's own words, injected blocks stripped, queued messages kept
find "$FIX" -name '*.jsonl' | "$MF" extract "$T/x" >/dev/null
all=$(cat "$T/x"/*.txt)
check "extracts the three fixture sessions" '[ "$(ls "$T/x"/*.txt | wc -l | tr -d " ")" = 3 ]'
check "keeps typed corrections" 'grep -q "Intl.DateTimeFormat does it natively" <<<"$all"'
check "keeps messages queued while the agent was busy" 'grep -q "before any new package" <<<"$all"'
check "strips multi-line injected blocks" '! grep -q "must never be mined" <<<"$all"'
check "skips the assistant side" '! grep -q "install moment.js" <<<"$all"'
check "headers name the source transcript" 'grep -q "^### .*/projects/-home-dev-globex-billing/7e1c-billing.jsonl" <<<"$all"'

# codex sessions
mkdir -p "$T/c/.codex/sessions/2026/09/01"
echo '{"type":"response_item","payload":{"type":"message","role":"user","content":[{"type":"input_text","text":"keep the PR to one concern"}]}}' >"$T/c/.codex/sessions/2026/09/01/r.jsonl"
echo "$T/c/.codex/sessions/2026/09/01/r.jsonl" | "$MF" extract "$T/cx" >/dev/null
check "extracts codex user messages" 'find "$T/cx" -name "*.txt" -exec cat {} + | grep -q "one concern"'

# holdout: the same sessions on every machine, decided by the path below projects/
for i in $(seq 200); do
  name="-p/s$i.jsonl"
  [ $(($(printf %s "$name" | cksum | cut -d' ' -f1) % 7)) -eq 0 ] && break
done
for root in "$T/a/projects" "$T/b/deeper/projects"; do
  mkdir -p "$root/-p" && cp "$FIX/projects/-home-dev-globex-billing/7e1c-billing.jsonl" "$root/$name"
done
printf '%s\n' "$T/a/projects/$name" "$T/b/deeper/projects/$name" | "$MF" extract "$T/h" >/dev/null
check "a held-out session is held out under any home path" '[ "$(ls "$T/h/holdout"/*.txt | wc -l | tr -d " ")" = 2 ]'
cp "$FIX/projects/-home-dev-globex-billing/7e1c-billing.jsonl" "$T/history.jsonl"
echo "$T/history.jsonl" | "$MF" extract "$T/hist" >/dev/null
check "prompt history is never held out" '[ -z "$(ls "$T/hist/holdout" 2>/dev/null)" ]'

# handles are validated before touching the filesystem
check "rejects path-like handles" '! "$MF" remove ../x 2>/dev/null'
check "rejects handles with spaces" '! "$MF" remove "a b" 2>/dev/null'

echo
[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
