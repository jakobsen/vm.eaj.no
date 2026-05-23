# List available recipes
default:
    @just --list

# Deploy the current remote main branch to prod
deploy:
    ssh root@eaj.no 'bash -lc /root/vm/deploy.sh'

# Remote into the running server in prod
remote:
    ssh -t root@eaj.no /root/vm/_build/prod/rel/tipping/bin/tipping remote

# Run tests in watch mode
watch:
    fd --hidden -e ex -e exs -e heex | entr mix test --stale
