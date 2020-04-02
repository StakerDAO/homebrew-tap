#! /usr/bin/env bash
tezos_client_version="2020-03-11-ledger-patched"
template_version="master"
config_template_link="https://raw.githubusercontent.com/StakerDAO/homebrew-tap/$template_version/scripts/config-template.yaml"

brew tap stakerdao/tap
brew install stakerdao/tap/tezos-client-patched

tezos_client="$(brew --cellar stakerdao/tap/tezos-client-patched)/$tezos_client_version/bin/tezos-client"

brew install stakerdao/tap/stkr-token-cli

config_dir="$HOME/.stkr-token-cli"
config_file="$config_dir/config.yaml"

mkdir -p "$config_dir"

rm "$config_file"
curl -s "$config_template_link" | sed "s%_TEZOS_CLIENT_PATH%$tezos_client%g" > "$config_file"
echo "Default config file written to $config_file"
