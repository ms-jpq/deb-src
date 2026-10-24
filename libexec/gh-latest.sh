#!/usr/bin/env -S -- bash -Eeu -O dotglob -O nullglob -O extglob -O failglob -O globstar

set -o pipefail

TMP="$1"
REPO="$2"
NAME="${REPO/\//.}"
CACHE="$TMP/$NAME.30-days.cache"

mkdir -v -p -- "$TMP" >&2

if [[ -z ${LOCKED:-} ]] && command -v -- flock > /dev/null; then
  LOCK="$TMP/$NAME.lock"
  LOCKED=1 exec -- flock "$LOCK" "$0" "$@"
fi

if [[ -f $CACHE ]]; then
  find "$CACHE" -type f -mmin '+60' -delete
fi

if ! [[ -f $CACHE ]]; then
  CURL=(
    curl
    --fail
    --location
    --no-progress-meter
    --max-time 60
  )

  read -r -d '' -- JQ <<- 'JQ' || true
add | map(select(.draft == false and .prerelease == false) | select((.published_at | fromdateiso8601) <= $cutoff)) | max_by(.published_at) | .tag_name // empty
JQ

  CUTOFF="$(date --date='30 days ago' +%s)"
  TAG="$(
    PAGE=1
    while :; do
      RELEASES="$("${CURL[@]}" -- "https://api.github.com/repos/$REPO/releases?per_page=100&page=$PAGE")"
      printf -- '%s\n' "$RELEASES"
      COUNT="$(jq --exit-status 'length' <<< "$RELEASES")"
      if ((COUNT < 100)); then
        break
      fi
      PAGE="$((PAGE + 1))"
    done | jq --exit-status --raw-output --slurp --argjson cutoff "$CUTOFF" "$JQ"
  )"

  printf -- '%s' "$TAG" > "$CACHE"
fi

exec -- cat -- "$CACHE"
