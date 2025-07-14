#!/usr/bin/env -S -- bash -Eeu -o pipefail -O dotglob -O nullglob -O extglob -O failglob -O globstar

set -o pipefail

VAR="${0%/*}/../var"
BUCKET="s3://${S3_BUCKET:=""}"

S3HOST='s3.ca-west-1.amazonaws.com'
export -- AWS_ACCESS_KEY AWS_SECRET_KEY
export -- AWS_SHARED_CREDENTIALS_FILE="$HOME/.config/aws/credentials"
S3=(
  "$(realpath -- "$VAR/venv/bin/s3cmd")"
  --no-mime-magic
  --host "$S3HOST"
  --host-bucket "%(bucket).$S3HOST"
)

case "${1:-""}" in
'' | ls)
  "${S3[@]}" ls --recursive --human-readable-sizes -- "$BUCKET"
  ;;
push)
  env --chdir "$VAR/s3" -- "${S3[@]}" sync --delete-removed -- ./ "$BUCKET"
  ;;
*)
  set -x
  exit 2
  ;;
esac
