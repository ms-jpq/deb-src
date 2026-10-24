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
    --retry 3
  )
  if [[ -n ${GH_TOKEN:-} ]]; then
    CURL+=(--header "Authorization: Bearer $GH_TOKEN")
  fi

  read -r -d '' -- JQ <<- 'JQ' || true
map(select(.draft == false and .prerelease == false)
  | select(.tag_name | contains("/") | not)
  | select((.published_at | fromdateiso8601) <= $cutoff))
| max_by(.published_at) | .tag_name // empty
JQ

  CUTOFF="$(date --date='30 days ago' +%s)"
  PAGE=1
  while :; do
    RELEASES="$("${CURL[@]}" -- "https://api.github.com/repos/$REPO/releases?per_page=30&page=$PAGE")"
    TAG="$(jq --raw-output --argjson cutoff "$CUTOFF" "$JQ" <<< "$RELEASES")"
    if [[ -n $TAG ]]; then
      break
    fi
    COUNT="$(jq --exit-status 'length' <<< "$RELEASES")"
    if ((COUNT < 30)); then
      tee <<- EOF >&2
No release at least 30 days old: $REPO
EOF
      exit 1
    fi
    PAGE="$((PAGE + 1))"
  done

  printf -- '%s' "$TAG" > "$CACHE"
fi

exec -- cat -- "$CACHE"
