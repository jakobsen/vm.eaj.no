# List available recipes
default:
    @just --list

# Run Credo and tests
check:
    mix credo
    mix test

# Deploy the current remote main branch to prod
deploy: check
    ssh root@eaj.no 'bash -lc /root/vm/deploy.sh'

# Run the dev server
dev:
    iex -S mix phx.server

# Remote into the running server in prod
remote:
    ssh -t root@eaj.no /root/vm/_build/prod/rel/tipping/bin/tipping remote

# Run tests in watch mode
watch:
    fd --hidden -e ex -e exs -e heex -e svg | entr mix test --stale
