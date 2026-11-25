---
name: cso-linux
description: Run gstack's security audit (/gstack-cso) inside the WSL Ubuntu VM so comprehensive mode works (Docker-isolated reproduction, scanners gitleaks/osv/semgrep/trivy/zizmor/schemathesis, repair candidates). Use for any security audit request on this Windows machine, "/gstack-cso", "audit de sécurité", "tests avancés", "--comprehensive", "pentest my app", "check for vulnerabilities". Always prefer this over running /gstack-cso natively on Windows.
---

# cso-linux: gstack CSO through the Ubuntu VM

Windows can only run CSO's static assessment. Comprehensive mode needs a Linux host with Docker. This machine has one: WSL2 distro `Ubuntu-24.04` (stored on `D:\WSL\Ubuntu`), with gstack, Docker 29, Node 22 and all 11 qualified CSO images installed under `root`.

## How to run an audit

1. **Load the real procedure.** Read `~/.claude/skills/gstack/cso/SKILL.md` and the section files it names (from the Windows install; same version as the VM). Follow it exactly, with the substitutions below.
2. **Launcher substitution.** Wherever the procedure says `gstack-cso <args>` (or `gstack-cso-launcher`), run instead:
   ```bash
   bash ~/.claude/skills/cso-linux/cso-wsl.sh <args>
   ```
   Windows paths in the args (`C:\...`, `C:/...`, `/c/...`) are translated to `/mnt/c/...` automatically.
3. **Control files** (submission/request JSON). Do not write them on Windows. Pipe the JSON into the VM, then pass the printed Linux path:
   ```bash
   P=$(printf '%s' "$JSON" | bash ~/.claude/skills/cso-linux/cso-wsl.sh ctl-write submit-1.json)
   bash ~/.claude/skills/cso-linux/cso-wsl.sh submit <run> "$P"
   bash ~/.claude/skills/cso-linux/cso-wsl.sh ctl-rm submit-1.json
   ```
4. **jq.** Not on Windows. Parse helper JSON with `node -e`, or run `jq` in the VM: `wsl.exe -d Ubuntu-24.04 -u root -- jq ...`.
5. **Comprehensive by default** when the user asks for advanced / full / runtime tests: add `--comprehensive` to `start`.

## Before the first call

Run `bash ~/.claude/skills/cso-linux/cso-wsl.sh status`. Expect `docker 29.x` and `gstack-cso 3.x`. If it fails, report **not assessed** with the error, and say how to fix it:
- VM stopped or broken: `wsl -d Ubuntu-24.04 -u root -- systemctl start docker`
- launcher missing: `wsl -d Ubuntu-24.04 -u root -- bash -lc "cd ~/.claude/skills/gstack && ./setup --prefix --no-skill-routing --no-skill-contracts --no-destructive-guard"`

## Notes

- Repos under `/mnt/c` work but read slower than the VM's own disk. Large repos: consider `--paths` prefixes as the procedure describes.
- The runtime needs dependency metadata (`package-lock.json`, `requirements.txt`, `Gemfile.lock`...). Without it, `doctor` reports `application-preparation: missing` and CSO stays static. That is a prerequisite, not a finding.
- Keep gstack in both places in sync: after `/gstack-upgrade` on Windows, also run `wsl -d Ubuntu-24.04 -u root -- bash -lc "cd ~/.claude/skills/gstack && git pull --ff-only && ./setup --prefix --no-skill-routing --no-skill-contracts --no-destructive-guard"`.
