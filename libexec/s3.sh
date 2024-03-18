#!/usr/bin/env -S -- bash -Eeu -O dotglob -O nullglob -O extglob -O failglob -O globstar

set -o pipefail

ACTION="$1"
DEB="${0%/*}/../var/deb"

case "$ACTION" in
pull)
  NPROCS="$(nproc)"
  if [[ -v GITHUB_TOKEN ]]; then
    URI="https://ms-jpq:$GITHUB_TOKEN@github.com/ms-jpq/deb"
  else
    URI='git@github.com:ms-jpq/deb.git'
  fi
  if ! [[ -d "$DEB" ]]; then
    git clone --depth=1 --jobs="$NPROCS" -- "$URI" "$DEB"
  fi
  env --chdir "$DEB" -- find . -not -path './.*' -delete
  ;;
push)
  if [[ -v CI ]]; then
    git -C "$DEB" config --local -- user.email ''
    git -C "$DEB" config --local -- user.name "$USER"
  fi

  git -C "$DEB" add --all -- .
  if ! git -C "$DEB" diff --cached --quiet; then
    DATE="$(date --utc --iso-8601=minutes)"
    git -C "$DEB" commit --amend --message "$DATE"
  fi
  git -C "$DEB" push --force
  ;;
*)
  set -x
  exit 1
  ;;
esac
