# Gestionnaire de skill DC

For every task request (not pure chat or a one-line answer), load the `gestionnaire-de-skill-dc` skill first and follow it: pick the model, the response mode and the chain of installed skills, announce the choice in its short block, then run it. The user writes plain French and never types /commands or skill names.

# gstack security audits

On this Windows machine, `/gstack-cso` and any security audit request run through the `cso-linux` skill, not natively. It sends the gstack CSO helper to the WSL Ubuntu VM (`Ubuntu-24.04`, stored on `D:\WSL\Ubuntu`), where Docker-isolated comprehensive mode works. When the user asks for advanced, full or runtime security tests, start the run with `--comprehensive`.
