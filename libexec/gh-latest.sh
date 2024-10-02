#!/usr/bin/env -S -- bash -Eeu -O dotglob -O nullglob -O extglob -O failglob -O globstar

set -o pipefail

TMP="$1"
REPO="$2"
NAME="${REPO/\//.}"
CACHE="$TMP/$NAME.cache"

mkdir -v -p -- "$TMP" >&2

if ! [[ -v LOCKED ]] && command -v -- flock > /dev/null; then
  LOCK="$TMP/$NAME.lock"
  LOCKED=1 exec -- flock "$LOCK" "$0" "$@"
fi

if [[ -f $CACHE ]]; then
  find "$CACHE" -type f -mmin '+60' -delete
fi

if ! [[ -f $CACHE ]]; then
  CURL=(
    curl
    --fail-with-body
    --location
    --no-progress-meter
    --max-time 60
  )
  if [[ -v GH_TOKEN ]]; then
    CURL+=(--oauth2-bearer "$GH_TOKEN")
  fi

  if [[ -v LATEST_TAG ]]; then
    CURL+=(-- "https://api.github.com/repos/$REPO/tags")
  else
    CURL+=(-- "https://api.github.com/repos/$REPO/releases/latest")
  fi

  JQ=(
    jq --exit-status
    --raw-output
  )

  if [[ -v LATEST_TAG ]]; then
    JQ+=('.[0].name')
  else
    JQ+=('.tag_name')
  fi

  LINES="$("${CURL[@]}" | "${JQ[@]}")"
  readarray -t -- TAGS <<< "$LINES"
  printf -- '%s' "${TAGS[0]}" > "$CACHE"
fi

exec -- cat -- "$CACHE"
