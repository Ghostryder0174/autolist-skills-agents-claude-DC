# Gestionnaire de skill DC

For every task request (not pure chat or a one-line answer), load the `gestionnaire-de-skill-dc` skill first and follow it: pick the model, the response mode and the chain of installed skills, announce the choice in its short block, then run it. The user writes plain French and never types /commands or skill names.

# gstack security audits

On this Windows machine, `/gstack-cso` and any security audit request run through the `cso-linux` skill, not natively. It sends the gstack CSO helper to the WSL Ubuntu VM (`Ubuntu-24.04`, stored on `D:\WSL\Ubuntu`), where Docker-isolated comprehensive mode works. When the user asks for advanced, full or runtime security tests, start the run with `--comprehensive`.

# No paid API usage

The user pays only for the Claude subscription. Never export or configure a paid API key (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `GROQ_API_KEY`...) for any skill or tool, and never add an agent-reach channel that needs a key (`xiaoyuzhou`, Whisper transcription).
- **SkillSpector**: always run `skillspector scan ... --no-llm`.
- **graphify**: keep `GRAPHIFY_BACKEND=none` (set in user env); never pass `--backend` with an API provider.
- **superpowers**: telemetry is off through `SUPERPOWERS_DISABLE_TELEMETRY=1`.
- Never install `claude-octopus` or `claude-mem` (rejected after security review).
