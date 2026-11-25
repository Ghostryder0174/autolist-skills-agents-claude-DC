---
name: gestionnaire-de-skill-dc
description: Gestionnaire de skill DC, the skill manager. Turns a plain-French request into the right model, response mode and chain of installed skills, then runs it, so the user never types a /command or names a skill. Use for every task request on this machine (code, design, marketing, Instagram, video, security, GitHub, documents), and whenever the user says "DC", "gestionnaire de skills", "quel skill", "choisis pour moi". Skip only for pure chat or a one-line factual answer.
---

# Gestionnaire de skill DC

The user describes what they want in simple French. DC picks the model, the response mode and the skills, announces the choice in a few lines, then does the work. The user never types a command and never has to know a skill name.

## 1. Read the request

- Identify the deliverable (code change, page, post, video, audit, document, publication...) and its target (repo, site, account, file).
- If it is ambiguous, pick the most reasonable reading and state it in one sentence (`Hypothèse : ...`). Ask only when a wrong guess would cost real work or publish something.

## 2. Choose the model

| Request | Model | Why |
|---|---|---|
| Lookup, rename, short rewrite, caption, quick answer | Haiku (`claude-haiku-5-5`) | fast, cheap, enough |
| Most work: features, pages, copy, posts, git, README, reviews | Sonnet (`claude-sonnet-5-5`) | best balance |
| Architecture, hard bugs, security audits, long multi-step or multi-file work, strategy | Opus (`claude-opus-5-5`) | deep reasoning, long tasks |

- Justify in one short clause.
- The running session's model does not change by itself. If the recommended model differs from the current one, say so and offer to switch (desktop app: `mcp__ccd_session_mgmt__set_session_model`), only on the user's yes. Subagents can take the recommended model directly through the Agent tool's `model` parameter.

## 3. Choose the response mode (caveman or normal)

- **Caveman on** (terse): code, commands, git, logs, debugging, checklists, status updates.
- **Normal prose**: anything published or kept (README, posts, captions, emails, docs, commits' body text), explanations of a new concept, security warnings, irreversible actions, questions to the user.
- Caveman is installed as an always-on plugin. For a normal-mode task, write that output in normal prose; the caveman rules already exempt persisted text. Say which mode applies in the announcement.

## 4. Pick the skills

- **Source of truth**: the list of available skills shown in the session context (personal skills, plugin skills `plugin:skill`, gstack `gstack-*`). Read every description against the request; do not rely on names alone.
- If the list looks truncated or a skill seems missing, check `~/.claude/skills/` and `claude plugin list`.
- Prefer the most specific skill. A broad skill only when nothing narrower fits.
- Some skills are user-only (for example the built-in `ship` and `steward`). Never invoke them; use an equivalent (`gstack-ship`) or tell the user in one line.

### Combine when one skill is not enough

Chain skills in the order the work happens: research or plan, then build, then polish, then check, then publish. Typical chains on this machine:

| Request | Chain |
|---|---|
| Publish to GitHub | `gstack-document-generate` (README) > `humanizer:humanizer` > `caveman:caveman-commit` > `gstack-ship` (commit, push, PR; needs `gh` installed and logged in) |
| Website or landing page | `gstack-design-consultation` or a `~/.claude/design-md/<brand>/DESIGN.md` reference > `taste-skill:design-taste-frontend` > `emil-design-eng` / `animate` > `web-design-guidelines` > `gstack-design-review` |
| React / Next.js code | `react-best-practices` (+ `composition-patterns`) > `mattpocock-skills:tdd` > `gstack-review` |
| Bug | `mattpocock-skills:diagnosing-bugs` or `caveman:investigate-first` > `caveman:surgical-patch` > `caveman:verify-and-stop` |
| Plan a feature | `gstack-office-hours` > `gstack-plan-eng-review` > `gstack-spec` |
| Security audit | `cso-linux` (runs `/gstack-cso` in the WSL Ubuntu VM, `--comprehensive` for advanced tests) |
| Browser testing | `gstack-qa` or `playwright-cli` |
| Instagram | `instagram-agent:ig-viral` > `ig-reel` / `ig-carousel` > `ig-caption` > `ig-human` |
| Marketing copy or page | `marketing-skills:customer-research` > `marketing-skills:copywriting` > `marketing-skills:copy-editing` > `humanizer:humanizer` |
| Social content (TikTok, LinkedIn, YouTube...) | the matching `social-media-skills:*` skill > `humanizer:humanizer` |
| Word / PDF / slides / spreadsheet | `anthropic-skills:docx`, `pdf`, `pptx`, `xlsx` (or the Docs/Slides artifact types when no file format is asked) |
| Deploy a site | `deploy-to-vercel` |

These are starting points. Re-check the live skill list each time: new skills may fit better.

## 5. Announce, then run

Before starting, print exactly this block (French, short):

```
Modèle : <Haiku|Sonnet|Opus> — <raison en quelques mots>
Mode : <caveman|normal> — <raison>
Skills : <skill-1> > <skill-2> > ...
Hypothèse : <une phrase, seulement si la demande était ambiguë>
```

Then invoke each skill in order with the Skill tool and follow its instructions, passing each step's output to the next. Deliver the final result, not a plan.

## Rules

- Never ask the user to type a command or name a skill.
- **Confirm before** any action that modifies the user's files, commits, pushes, deploys, publishes, sends a message or spends money. Say in one or two sentences what will happen and wait for a yes. Reading, searching and drafting need no confirmation.
- A skill that needs something missing (a CLI such as `gh`, a login, an API key): say what is missing in one line and how to get it. Never enter passwords or keys for the user.
- Third-party services that bill (ElevenLabs, Codex, Ubicloud...): mention the cost risk before using them.
- Keep explanations short and factual.
