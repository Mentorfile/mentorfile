@README.md

This repo is the public plugin and its marketplace. The site and API (mentorfile.com) live in the private repo `mentorfile/web`, checked out next to this one at `../web`; its CLAUDE.md has the architecture, setup and launch checklist.

## How the plugin works

- `skills/mine` is the one command owners need: mine new sessions, distill, show what changed, leak scan, then publish on an explicit yes. `skills/find` and `skills/get` are for using other people's mentorfiles.
- The skills call `scripts/mf` (bash, curl, jq; must run on macOS bash 3.2). It talks to `MENTORFILE_URL` (default https://mentorfile.com).
- Sign-in is GitHub's device flow (`mf login`): no accounts or API keys; the GitHub handle is the identity. The token lives in `~/.mentorfile/token`.
- Installed mentorfiles are skills named `ask-<handle>` in every `~/.claude*/skills` and in `~/.agents/skills` (Codex).

## Checks

- `claude plugin validate .`
- `bash -n plugins/mentorfile/scripts/mf`
- End to end against a local copy of the site: see `../web/CLAUDE.md`.

## Releasing

Bump `version` in both `plugins/mentorfile/.claude-plugin/plugin.json` and `plugins/mentorfile/.codex-plugin/plugin.json`; installed users only get updates on a version change.
