#!/usr/bin/env sh
# Populate env vars with secrets from Bitwarden vault

if [ ! -x "$(command -v bw)" ]; then
    echo "Bitwarden CLI tool $(bw) not found."
    exit 1
fi

[ -z "$BW_SESSION" ] && export BW_SESSION=$(bw unlock --raw)

export TF_VAR_cloudflare_api_token=$(bw get password "cloudflare-api-token")
