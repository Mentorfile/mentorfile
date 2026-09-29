---
name: find
description: Search mentorfile.com for mentorfiles (personas distilled from how real people work with AI) that fit the problem at hand. Use when the user runs /mentorfile:find, asks who could review or advise on something, or wants a second opinion from someone experienced in a specific area.
---

# mentorfile find

`MF` is the CLI at `scripts/mf` in the plugin root, two folders up from this skill's directory.

1. Turn the request into a short search: the problem and its domain, in plain words ("postgres migration without downtime", "pricing page copy"). If the user gave no query, derive one from what they're working on in this conversation.
2. Run `MF find <query>`. If nothing matches, try one broader query.
3. Show at most five results, best fit first: handle, what they're strongest at, price, session count, and the page URL. Say in one line why each fits.
4. Offer to install one with `/mentorfile:get <handle>`. Don't install without the user's go-ahead, and never buy anything on their behalf.
