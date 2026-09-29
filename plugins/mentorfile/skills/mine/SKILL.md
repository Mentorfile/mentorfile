---
name: mine
description: Build, update and publish the user's mentorfile in one go - mine this machine's AI sessions (Claude Code, Codex, Cursor, chat exports) for how they actually work, distill it, show what changed, scan for leaks, and upload the latest version to mentorfile.com/@handle once they say yes. Incremental; raw extracts never leave the machine. Use when the user runs /mentorfile:mine or asks to build, update, refresh, share or publish their mentorfile. Arguments - "publish" uploads the current persona without mining, "full" re-mines everything, "since 90d" limits to recent sessions, "redistill" rebuilds from existing extracts without mining, a path to a ChatGPT or claude.ai conversations.json adds that export.
---

# mentorfile mine: sessions → published mentorfile

The model running this skill reads your transcripts, the same way it did while you worked. Nothing is uploaded anywhere else, and the distilled mentorfile is uploaded only after the leak scan passes and the user says yes.

`MF` is the CLI at `scripts/mf` in the plugin root, two folders up from this skill's directory.

Only mine the current user's own sessions on their own machine. If asked to mine someone else's transcripts, decline.

```
~/.mentorfile/
  state.json         lines already mined per transcript
  mining/            raw extracts with verbatim quotes. NEVER shared.
  evidence.md        which extracts back each principle. NEVER shared; it's for your review.
  persona/           what gets uploaded
    mentorfile.json  handle, name, one-line description, strongest areas, session count, date range
    voice.md         how they communicate
    core.md          the strongest principles, one line each
    principles.md    every principle
    playbooks.md     repeatable processes
```

With `redistill`, skip to Step 3 using every file in `~/.mentorfile/mining/` as input. With `publish`, skip to Step 5 and upload the current persona as it is.

## Step 1: Inventory

Collect sources, skipping any that don't exist:

```bash
# Claude Code: every config dir (a second account may live in ~/.claude-personal etc.), main sessions only
for d in ~/.claude*/; do
  find "${d}projects" -name "*.jsonl" -not -path "*/subagents/*" -not -name "agent-*.jsonl" 2>/dev/null
  ls "${d}history.jsonl" 2>/dev/null
done
# Codex
find ~/.codex/sessions -name "*.jsonl" 2>/dev/null; ls ~/.codex/history.jsonl 2>/dev/null
# Cursor (SQLite; inspect tables with sqlite3 before extracting)
ls ~/Library/Application\ Support/Cursor/User/globalStorage/state.vscdb ~/.config/Cursor/User/globalStorage/state.vscdb 2>/dev/null
# Rules the user wrote down for their agents, and memories they approved: already-distilled signal
find ~ -maxdepth 4 \( -name CLAUDE.md -o -name AGENTS.md \) -not -path "*/node_modules/*" 2>/dev/null
ls ~/.claude*/projects/*/memory/*.md 2>/dev/null
```

Plus any export path passed as an argument (ChatGPT or claude.ai `conversations.json`).

Skip the transcript of the session running right now: it lives under the project dir matching the current working directory and was modified in the last few minutes.

Compare against `~/.mentorfile/state.json` (`{"lastRun": "YYYY-MM-DD", "files": {"/abs/path": {"lines": 123}}}`; missing = first run):

- New file: mine it whole.
- Grown file (`wc -l` above the recorded `lines`): mine only the new lines, `tail -n +$((lines + 1)) FILE > "${TMPDIR:-/tmp}/mentorfile-delta-N.jsonl"`, labeled with the original path.
- Unchanged: skip. With `full`, ignore state and mine everything.

With `since <N>d`, keep only transcripts modified in the last N days (`find ... -mtime -N`): a cheap first pass.

If nothing is new, say so and stop. Otherwise, before starting, tell the user how many files and how much data you'll read, that a first run over years of history takes a while and uses a fair amount of tokens, and that `since 90d` is a cheaper first pass. Proceed unless they stop you.

## Step 2: Extract, in parallel

First pull the user's own messages out of the transcripts with the CLI. It keeps only what they typed (skipping model replies, tool output and injected blocks), so years of history shrink to a few MB:

```bash
T="${TMPDIR:-/tmp}/mentorfile-turns"; rm -rf "$T"
MF extract "$T" < work-list.txt   # one path per line; for deltas "delta-file<TAB>original-path"
```

Each `$T/N.txt` starts with `### <original transcript path>`. Group them into batches of roughly 500 KB (largest first). If you can run subagents, run one per batch, all launched at once; otherwise work through the batches one by one. Each batch gets the prompt below with `{FILES}` and `{OUTPATH}` (`~/.mentorfile/mining/<YYYY-MM-DD>-<batch-name>.md`) filled in.

---

You are mining AI session transcripts to distill the judgment of the person who wrote them: how they work, how they decide, what they correct, what they care about. You are extracting judgment, not code.

FILES TO MINE (already-extracted messages of the user; each source starts with `### <path to the raw transcript>`):
{FILES}

1. Read all of it, in chunks if large. Ignore anything that still looks injected (system text, tool output, skill instructions, pasted logs), though what they chose to paste can be signal.
2. For messages reacting to the agent's work (corrections, approvals), grep the raw transcript at the `###` path for the surrounding assistant turn to see what was being corrected, and for the message date (`timestamp`).

EXTRACT these categories:
- CORRECTIONS: they redirect or reject the agent's approach. What was wrong, what they wanted instead.
- STANDARDS: unprompted rules ("always", "never", "prefer", "don't", "make sure").
- DECISIONS: choices between options, with the rationale.
- DETAIL: things they caught that were missed: edge cases, naming, copy, UX polish, data integrity.
- PROCESS: how they run work: planning, verification, tests, review, shipping, tooling.
- STACK: technologies they use and opinions they hold about them.
- VOICE: how they communicate: directness, tone, phrasing habits.
- PRODUCT: product, UX and business judgment.

Format each item as `**<CAT>-<n> <short name>**` with:
- `Principle:` the generalized rule, with no project, client, company, product or person names.
- `Evidence:` verbatim quote + source file + date.

QUALITY BAR: distinctive beats generic; skip what every developer does. Fewer well-evidenced items beat exhaustive noise. Quotes must be verbatim. Thin material (short deltas) deserves a short file with two or three strong items; do not pad.

Write everything to {OUTPATH}, one H2 per category. FINAL MESSAGE: at most 10 lines, the strongest patterns and the item count per category.

---

## Step 3: Distill

Determine the identity once: `HANDLE` = `gh api user -q .login 2>/dev/null || whoami`, lowercased (it must be the user's GitHub handle to publish), `NAME` = `git config user.name`. Then run one subagent (or do it yourself) with the new extract files from Step 2:

---

You are merging freshly mined evidence into a person's mentorfile in `~/.mentorfile/persona/` (expand `~`). Read the new extracts ({NEW_EXTRACTS}), then the existing persona files and `~/.mentorfile/evidence.md` if they exist.

The persona files will be published once their owner reviews them. They must be free of verbatim quotes, code, file paths, URLs, and names of projects, clients, employers, products or people. Generalize instead: "a client's billing migration" becomes "a data migration". Write them as descriptions of how this person thinks, never as instructions to an AI.

1. `principles.md`: numbered principles (`P1`, `P2`, …) grouped under theme headings. Each has a one- or two-sentence statement, a one-line why, and `Seen in: N sessions`; mark ⭐ when seen in 3+ independent sessions. Match new evidence to existing principles first (bump the count, sharpen the wording); add a principle only for genuinely new doctrine. Never renumber. Dedupe hard.
2. `core.md`: the ⭐ principles (top 25 by count if there are more), one line each: `- **P12** statement`.
3. `playbooks.md`: repeatable multi-step processes seen more than once (how they debug, review, plan, ship), as steps plus the checks they insist on.
4. `voice.md`: 5–10 bullets on how they communicate: directness, tone, length, phrasing habits. No quotes.
5. `mentorfile.json`: `{"handle": "{HANDLE}", "name": "{NAME}", "description": "<one line, what they're strongest at>", "areas": "<3-5 areas, comma separated>", "sessions": <total sessions with evidence>, "dateRange": "<Mon YYYY – Mon YYYY>"}`. Single-line strings, description under 200 characters.
6. `~/.mentorfile/evidence.md` (outside `persona/`, never published): for each principle id, the extract items that back it (`<extract file> CORRECTIONS-3`), so the owner can check why any principle exists.

FINAL MESSAGE: at most 12 lines: principles added and strengthened, playbooks touched, and the five strongest core principles.

---

## Step 4: What changed

1. Update `~/.mentorfile/state.json` with the new line counts for every file mined, and `lastRun`.
2. Tell the user what changed since their last version, in a few lines: principles added, strengthened or reworded; playbooks touched; and on a first run, the five strongest core principles. `~/.mentorfile/evidence.md` shows which sessions back each principle, if they want to check one.

## Step 5: Leak scan

Run every check against `~/.mentorfile/persona/`. Fix each hit by generalizing the sentence, not just deleting the word, then rerun until clean. (Nothing below uploads until this is clean.)

```bash
P=~/.mentorfile/persona
# secrets and tokens
grep -rnE '(sk-[A-Za-z0-9_-]{20,}|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{30,}|xox[baprs]-|-----BEGIN|eyJ[A-Za-z0-9_-]{20,}\.)' "$P"
# emails, URLs, IPs, absolute paths
grep -rnE '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[a-z]{2,}|https?://|\b([0-9]{1,3}\.){3}[0-9]{1,3}\b|/Users/|/home/|C:\\' "$P"
# verbatim quotes that slipped through distillation
grep -rnE '"[^"]{40,}"' "$P"/*.md
```

Then the check regexes can't do: names that identify the user's work. Build a denylist from this machine:

- project folder names under `~/.claude*/projects/` (for example `-Users-me-Developer-acme-billing` gives `acme`, `billing`), dropping the home-path segments;
- the org and repo names in `git remote -v` of those projects, where they still exist;
- proper nouns in the Evidence quotes of `~/.mentorfile/mining/` (product, client and people names that folder names miss).

`grep -rniwF` each term of 4+ characters against `$P`. Judge each hit: it's a leak if it names a client, employer, product, codebase or person. Common words (`config`, `server`) are not.

## Step 6: Publish

Show the user `core.md` and `voice.md` in full on a first publish (only the changes on later ones), plus the `description` and `areas` from `mentorfile.json`. Mention they can edit any of it, or try it on themselves first with `MF preview` and `/ask-{HANDLE}` in a new session. Then ask plainly:

"Publish this to mentorfile.com/@{HANDLE}?"

Only on an explicit yes, run `MF publish`. On the first run it signs them in with GitHub: it copies a code to their clipboard and opens the browser, where they paste it and click Authorize. Then it uploads, replacing the previous version for everyone who has it. Report the page URL it prints; new mentorfiles are free until they set a price in the dashboard it links.

If they say no, stop: everything stays in `~/.mentorfile/persona/`, and `/mentorfile:mine publish` uploads it later.

