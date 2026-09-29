# mentorfile

<img src="assets/mentorfile.svg" alt="Mentorfile pixel mf logo" width="80" height="80">

**Install someone's judgment.**

A mentorfile is a skill for Claude Code and Codex, distilled from how one person actually works with AI: what they corrected, what they rejected, what they kept insisting on. Find someone who's solved your kind of problem at [mentorfile.com](https://mentorfile.com), install their mentorfile, and ask it to look at your plan.

## Install the plugin

### Claude Code

```
/plugin marketplace add mentorfile/mentorfile
```
```
/plugin install mentorfile@mentorfile
```

### Codex

```
codex plugin marketplace add mentorfile/mentorfile
```
```
codex plugin add mentorfile@mentorfile
```

Works on macOS and Linux, and on Windows through Git Bash, which Claude Code on Windows already uses. Codex on Windows needs [Git for Windows](https://gitforwindows.org) installed. The plugin needs only bash and curl; see the [CLI docs](https://mentorfile.com/cli).

## Use someone's

- `/mentorfile:find <what you're working on>` searches mentorfile.com.
- `/mentorfile:get <handle>` installs it as the skill `ask-<handle>`. Paid ones send you to checkout first. `/mentorfile:get` with no handle updates everything you have.
- Then ask `/ask-<handle>` (or `$ask-<handle>` in Codex) to review a plan, diff or decision. Answers start with "Simulated `<handle>`", cite the principle behind each point, and say so when that person's sessions don't cover the question.

## Publish yours

One command: `/mentorfile:mine`.

- It reads your Claude Code, Codex and Cursor history on your machine and distills your side of it into principles, playbooks and a voice note, each principle counted by the sessions behind it.
- It shows you what changed, scans for anything private, and asks before publishing to `mentorfile.com/@yourhandle`. The first time, it signs you in with GitHub: your GitHub account is your mentorfile account, with no signup or API key.
- Run it again whenever you like. It only reads new sessions and replaces your published version. Edit `~/.mentorfile/persona/` freely, and try it on yourself first with `mf preview`.
- At the end it sums up what was mined and gives you your public page and a suggested price. Everyone gets the same rule, based on sessions and ⭐ principles ([see it](https://mentorfile.com/#pricing)). It's free until you set a price (one-time or monthly) in your dashboard.
- `mf unpublish` takes it down any time; copies people already installed stay on their machines.

## What it looks for

Mining reads only your side of each conversation and sorts what it finds into eight kinds:

- **Corrections:** you stopped or redirected the agent: what was wrong, what you wanted.
- **Standards:** rules you set unprompted (always, never, prefer, don't).
- **Decisions:** choices between options, and why.
- **Details:** things you caught that were missed: edge cases, naming, copy, polish.
- **Process:** how you plan, verify, test, review and ship.
- **Stack:** the tools you use and what you think of them.
- **Voice:** how you communicate: tone, length, directness.
- **Product:** product, UX and business calls.

Before anything is published, a leak scan checks the result for:

- secrets and tokens (API keys, cloud keys, GitHub and Slack tokens, private keys, JWTs);
- emails, URLs, IP addresses and file paths;
- quotes copied from your sessions instead of generalized;
- names that identify your work, built from your own machine: your project folders, your git remotes, and the product, client and people names in your extracts.

Both lists live in [`plugins/mentorfile/skills/mine/SKILL.md`](plugins/mentorfile/skills/mine/SKILL.md) (Step 2 and Step 5). Think it should look for something else, or catch another kind of leak? [Open an issue](https://github.com/mentorfile/mentorfile/issues/new) or a pull request.

## What stays on your machine

- Your transcripts. Mining runs locally through the model you already use; nothing is uploaded anywhere else.
- The raw extracts with verbatim quotes (`~/.mentorfile/mining`) and the evidence file linking principles to sessions.

## What gets published

Only your principles, playbooks, a voice note and the profile line that goes with them. Nothing is uploaded until the [leak scan](#what-it-looks-for) is clean and you say yes. The [CLI docs](https://mentorfile.com/cli) list every command and exactly what it sends.

## Layout

```
plugins/mentorfile/   the plugin: skills (mine, find, get) and scripts/mf, the CLI they call
web/                  mentorfile.com: Next.js, Neon Postgres, GitHub sign-in, Lemon Squeezy
```

The plugin is MIT licensed.
