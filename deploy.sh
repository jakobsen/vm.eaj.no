#!/usr/bin/env bash

set -e

git pull origin main


mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy

MIX_ENV=prod mix release --overwrite

set -a
source "./.env"
set +a
_build/prod/rel/tipping/bin/migrate

systemctl restart vm_tipping
