#!/usr/bin/env -S -- bash -Eeu -O dotglob -O nullglob -O extglob -O failglob -O globstar

set -o pipefail

ACTION="$1"
DEB="${0%/*}/../var/deb"

case "$ACTION" in
pull)
  NPROCS="$(nproc)"
  if ! [[ -d "$DEB" ]]; then
    git clone --depth=1 --jobs="$NPROCS" -- 'https://github.com/ms-jpq/shell_rc' '$@'
  fi
  env --chdir "$DEB" -- find . -not -path './.git*' -delete
  ;;
push)
  if [[ -v CI ]]; then
    git -C "$DEB" config --local -- user.email ''
    git -C "$DEB" config --local -- user.name "$USER"
  fi
  ;;
*)
  set -x
  exit 1
  ;;
esac
