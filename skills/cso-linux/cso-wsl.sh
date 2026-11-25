#!/usr/bin/env bash
# Bridge: run gstack-cso inside the WSL Ubuntu VM, where Docker-isolated
# "comprehensive" audits are supported. Called from Git Bash on Windows.
#
#   cso-wsl.sh <gstack-cso args...>     run the Linux launcher (Windows paths are translated)
#   cso-wsl.sh ctl-write <name>         write stdin to /root/.cso-ctl/<name> (0600), print its Linux path
#   cso-wsl.sh ctl-rm <name>            delete /root/.cso-ctl/<name>
#   cso-wsl.sh linux-path <winpath>     print the /mnt/... path for a Windows path
#   cso-wsl.sh status                   check that the VM, Docker and the launcher answer
set -u
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*' WSL_UTF8=1
DISTRO="${CSO_WSL_DISTRO:-Ubuntu-24.04}"
LAUNCHER=/root/.claude/skills/gstack/bin/gstack-cso-launcher
CTL=/root/.cso-ctl

to_linux() {
  local p="$1"
  case "$p" in
    [A-Za-z]:[\\/]*)            # C:\x or C:/x
      local d; d=$(printf %s "${p:0:1}" | tr 'A-Z' 'a-z')
      printf '/mnt/%s%s' "$d" "$(printf %s "${p:2}" | tr '\\' '/')" ;;
    /[a-zA-Z]/*)                # Git Bash /c/x
      local d; d=$(printf %s "${p:1:1}" | tr 'A-Z' 'a-z')
      printf '/mnt/%s%s' "$d" "${p:2}" ;;
    *) printf %s "$p" ;;
  esac
}

run() { wsl.exe -d "$DISTRO" -u root -- "$@"; }

case "${1:-}" in
  ctl-write)
    name="${2:?name required}"; [[ "$name" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "bad name" >&2; exit 2; }
    run bash -c "umask 077; mkdir -p $CTL; cat > $CTL/$name; echo $CTL/$name" ;;
  ctl-rm)
    name="${2:?name required}"; [[ "$name" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "bad name" >&2; exit 2; }
    run rm -f "$CTL/$name" ;;
  linux-path)
    to_linux "${2:?path required}"; echo ;;
  status)
    run bash -c "docker info --format 'docker {{.ServerVersion}}' && test -x $LAUNCHER && $LAUNCHER --help | head -1" ;;
  *)
    args=()
    for a in "$@"; do args+=("$(to_linux "$a")"); done
    run "$LAUNCHER" "${args[@]}" ;;
esac
