#!/usr/bin/env bash

set -eo

pushd /root/vm
trap 'popd > /dev/null' EXIT

git pull origin main

set -a; source "./.env"; set +a

mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.setup
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix release --overwrite


_build/prod/rel/tipping/bin/migrate

systemctl restart vm_tipping
