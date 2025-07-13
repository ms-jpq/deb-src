#!/usr/bin/env -S -- bash -Eeu -o pipefail -O dotglob -O nullglob -O extglob -O failglob -O globstar

set -o pipefail

S3="${0%/*}/../var/venv/bin/s3cmd"

export -- AWS_ACCESS_KEY AWS_SECRET_KEY
export -- AWS_SHARED_CREDENTIALS_FILE="$HOME/.config/aws/credentials"

exec -- "$S3" "$@"
