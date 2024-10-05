#!/usr/bin/env -S -- bash -Eeu -O dotglob -O nullglob -O extglob -O failglob -O globstar

set -o pipefail

LS="$(tr --squeeze-repeats -- ' ' | tr -- '#' '$')"
readarray -t -- LINES <<< "$LS"

declare -A -- HOSTTYPES REMAPS
HOSTTYPES=(
  [x86_64]=amd64
  [aarch64]=arm64
)
export -- VERSION HOSTTYPE GOARCH

for LINE in "${LINES[@]}"; do
  if [[ -z $LINE ]]; then
    continue
  fi
  read -r -- VERSION NAME COPY URI REMAP <<< "$LINE"

  REMAPS=()
  REMAP="$(tr -- ',' '\n' <<< "${REMAP#'%'}")"
  readarray -t -- RS <<< "$REMAP"

  for R in "${RS[@]}"; do
    if [[ -z $R ]]; then
      continue
    fi
    FROM="${R%%=*}"
    TO="${R#*=}"
    REMAPS["$FROM"]="$TO"
  done

  for HT in "${!HOSTTYPES[@]}"; do
    GOARCH="${HOSTTYPES["$HT"]}"
    REMAP="${REMAPS["$HT"]:-""}"
    DPKG_ARCH="$GOARCH"

    case "$REMAP" in
    !)
      continue
      ;;
    ~)
      HOSTTYPE=''
      ;;
    all)
      DPKG_ARCH='all'
      ;;
    *)
      HOSTTYPE="${REMAP:-"$HT"}"
      ;;
    esac

    printf -- '%s ' "$DPKG_ARCH" "$VERSION"
    envsubst <<< "$NAME!$URI!$COPY"
  done
done | uniq | tr -- ' ' '!'
