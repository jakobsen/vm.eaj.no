#!/usr/bin/env bash

set -e

# Setup
git pull origin main

set -a
source "./.env"
set +a

mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
MIX_ENV=prod mix ecto.migrate

# Run the server
systemctl restart vm_tipping
