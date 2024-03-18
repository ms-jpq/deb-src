#!/usr/bin/env -S -- bash -Eeu -O dotglob -O nullglob -O extglob -O failglob -O globstar

set -o pipefail

ACTION="$1"

case "$ACTION" in
push) ;;
pull) ;;
*)
  set -x
  exit 1
  ;;
esac
