---
name: continue
description: >-
  Resume the project roadmap from where it was left. Use when the user asks to
  continue, resume or pick up the work ("sigue", "continúa", "sigue con M1",
  "siguiente issue", "¿por dónde íbamos?", "/continue M1", "/continue #12"),
  at the start of a new session about this project, or before starting any
  milestone or issue.
---

# Continue the roadmap

Pick up the work with no context beyond this repo, then carry it through the
normal workflow. The user wants to say as little as possible: work out the
rest from the sources below and only ask about real decisions.

## 1. Orient (read, don't change anything yet)

1. `docs/ROADMAP.md` is already in context through `CLAUDE.md`: current
   milestone, order of issues, decisions and where things live.
2. Check the live state:
   ```bash
   git status -sb && git fetch -q && git log --oneline -5 origin/master
   gh pr list                                   # anything in flight?
   gh issue list --milestone "<current milestone>" --state open
   gh run list --branch master --limit 3        # CI health on master
   ```
   (Unset `GH_TOKEN` before `gh` if it fails with a bad-credentials error.)
3. Choose the target: the issue or milestone the user named, else the next
   open issue in the order the roadmap gives. An open PR or a red run on
   `master` comes first: finish or fix it before starting something new. A
   PR labeled `owner-review` waits for the owner: remind them of it and go
   on with the next issue meanwhile.
4. Read the whole issue (`gh issue view <n> --comments`); its body includes
   follow-ups added later. Read the code it touches and its tests. For the
   engine or the bots, read the parts of `docs/RULES.md` involved as well.

## 2. Tell the user, briefly, in Spanish

One short message: which issue, what it will change, anything that needs
their decision. Then continue without waiting unless there is a real decision
or something only they can do (passwords, Apple ID, license acceptance,
connecting the iPhone).

## 3. Do it (AGENTS.md → Workflow and Testing)

- Branch `feat|fix|chore/<issue>-<slug>`; tests first or alongside; skills
  from AGENTS.md → Skills for the area.
- `tool/ci.sh` until green; UI changes checked on the simulator with a
  screenshot.
- PR with `Closes #n`, summary and verification. No co-author or
  "Generated with" lines, no mention of AI tools.
- Wait for the required checks on the final pushed head, then squash-merge
  (`gh pr merge --squash --delete-branch`) and check the run on `master`.

## 4. Leave the trail

- If the PR finished a milestone, made a decision, or moved something, update
  `docs/ROADMAP.md` in that same PR (status table, "Next step", decisions
  with date and reason).
- Close the milestone on GitHub when its last issue closes.
- End with a short report to the user: what shipped (PR links), what's next.
