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

## Use someone's

- `/mentorfile:find <what you're working on>` searches mentorfile.com.
- `/mentorfile:get <handle>` installs it as the skill `ask-<handle>`. Paid ones send you to checkout first. `/mentorfile:get` with no handle updates everything you have.
- Then ask `/ask-<handle>` (or `$ask-<handle>` in Codex) to review a plan, diff or decision. Answers start with "Simulated `<handle>`", cite the principle behind each point, and say so when that person's sessions don't cover the question.

## Publish yours

One command: `/mentorfile:mine`.

- It reads your Claude Code, Codex and Cursor history on your machine and distills your side of it into principles, playbooks and a voice note, each principle counted by the sessions behind it.
- It shows you what changed, scans for anything private, and asks before publishing to `mentorfile.com/@yourhandle`. The first time, it signs you in with GitHub: your GitHub account is your mentorfile account, with no signup or API key.
- Run it again whenever you like. It only reads new sessions and replaces your published version. Edit `~/.mentorfile/persona/` freely, and try it on yourself first with `mf preview`.
- It's free until you set a price (one-time or monthly) in your dashboard.

## What stays on your machine

- Your transcripts. Mining runs locally through the model you already use; nothing is uploaded anywhere else.
- The raw extracts with verbatim quotes (`~/.mentorfile/mining`) and the evidence file linking principles to sessions.
- What gets published is principles, playbooks and a voice note, scanned for quotes, code, paths, secrets and the names of your clients, employers and products before you confirm.

## Layout

```
plugins/mentorfile/   the plugin: skills (mine, find, get) and scripts/mf, the CLI they call
web/                  mentorfile.com: Next.js, Neon Postgres, GitHub sign-in, Lemon Squeezy
```

The plugin is MIT licensed.
