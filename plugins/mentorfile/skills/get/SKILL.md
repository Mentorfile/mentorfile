---
name: get
description: Install or update mentorfiles from mentorfile.com as local skills for Claude Code and Codex. Use when the user runs /mentorfile:get <handle>, asks to install someone's mentorfile, or wants their installed mentorfiles updated (no handle updates all of them).
---

# mentorfile get

`MF` is the CLI at `scripts/mf` in the plugin root, two folders up from this skill's directory. Run it as `bash <path>`; on Windows that needs Git Bash (Claude Code already uses it; Codex users need Git for Windows).

1. Run `MF get <handle>` (or `MF get` with no handle to update every installed mentorfile).
2. Handle what it reports:
   - **installed**: done. The mentorfile is the skill `ask-<handle>` in every Claude Code config dir, and in `~/.agents/skills` for Codex.
   - **sign in required** (paid mentorfiles need to know who bought them): run `MF login` (it copies a code to the clipboard and opens GitHub; the user pastes it and clicks Authorize), then retry the get. If it printed a URL and code instead, show them to the user and run `MF login` again once they're done.
   - **needs purchase**: show the user the link it prints. They pay in the browser; once they say they're done, run the get again. Never try to buy on their behalf.
3. Tell the user how to use it: ask `/ask-<handle>` (Claude Code) or `$ask-<handle>` (Codex) to review a plan, diff or decision, or just say "ask <handle> about this". If it doesn't show up, start a new session. Answers begin with "Simulated <handle>:" because a mentorfile models their judgment; it isn't them.
4. To uninstall: `MF remove <handle>`.
