@README.md

This repo is the public plugin and its marketplace. The site and API (mentorfile.com) live in the private repo `mentorfile/web`, checked out next to this one at `../web`; its CLAUDE.md has the architecture, setup and launch checklist.

## How the plugin works

- `skills/mine` is the one command owners need: mine new sessions, distill, show what changed, leak scan, then publish on an explicit yes. `skills/find` and `skills/get` are for using other people's mentorfiles.
- The skills call `scripts/mf`. It needs only bash and curl and must run on macOS bash 3.2; when jq is missing, `ensure_jq` fetches the pinned jq release into `~/.mentorfile/bin` and verifies its SHA-256. On Windows (Git Bash: `uname -s` is MINGW/MSYS/CYGWIN) it fetches `jq-windows-*.exe` and wraps `jq` as `jq -b` so output has no CRLF; sign-in uses `clip.exe` and `start`. That path is untested on real Windows. Bumping jq means updating the version and all six checksums together. No other dependencies: no perl, python or node. It talks to `MENTORFILE_URL` (default https://mentorfile.com).
- Sign-in is GitHub's device flow (`mf login`): no accounts or API keys; the GitHub handle is the identity. The token lives in `~/.mentorfile/token`.
- mentorfile.com/cli documents every `mf` command and what it sends (`../web/app/cli/page.tsx`); update it in the same change as `mf`. The site's "What it looks for" section mirrors Step 2's categories and Step 5's leak scan in `skills/mine`.
- Installed mentorfiles are skills named `ask-<handle>` in every `~/.claude*/skills` and in `~/.agents/skills` (Codex).

## Checks

- `claude plugin validate .`
- `bash -n plugins/mentorfile/scripts/mf`
- End to end against a local copy of the site: see `../web/CLAUDE.md`.

## Releasing

Bump `version` in both `plugins/mentorfile/.claude-plugin/plugin.json` and `plugins/mentorfile/.codex-plugin/plugin.json`; installed users only get updates on a version change.
