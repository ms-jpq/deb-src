#!/usr/bin/env -S -- bash -Eeu -O dotglob -O nullglob -O extglob -O failglob -O globstar

set -o pipefail

LS="$(tr --squeeze-repeats -- ' ' | tr -- '#' '$')"
readarray -t -- LINES <<<"$LS"

declare -A -- HOSTTYPES REMAPS
HOSTTYPES=(
  [amd64]=amd64
  [aarch64]=arm64
)
export -- VERSION HOSTTYPE GOARCH

for LINE in "${LINES[@]}"; do
  if [[ -z "$LINE" ]]; then
    continue
  fi
  read -r -- VERSION TEMPLATE REMAP <<<"$LINE"

  REMAPS=()
  REMAP="$(tr -- ',' '\n' <<<"${REMAP#'%'}")"
  readarray -t -- RS <<<"$REMAP"

  for R in "${RS[@]}"; do
    if [[ -z "$R" ]]; then
      continue
    fi
    FROM="${R%%=*}"
    TO="${R#*=}"
    REMAPS["$FROM"]="$TO"
  done

  for HT in "${!HOSTTYPES[@]}"; do
    GOARCH="${HOSTTYPES["$HT"]}"
    HOSTTYPE="${REMAPS["$HT"]:-"$HT"}"
    if [[ "$HOSTTYPE" != '!' ]]; then
      printf -- '%s ' "$HT" "$VERSION"
      envsubst <<<"$TEMPLATE"
    fi
  done
done | uniq | tr ' ' '!'
