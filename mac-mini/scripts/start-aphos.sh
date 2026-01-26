#!/bin/bash
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin"
eval "$(/opt/homebrew/bin/brew shellenv)"
cd ~/repos/aphos

# Start game servers (prod=2567, dev=2568)
pnpm dev:server:prod &
pnpm dev:server:dev &

# Start web frontends
cd packages/web
rm -rf .next 2>/dev/null

# Use pnpm exec to find local next binary
pnpm exec dotenv -e ../../.env -- pnpm exec next dev -p 4000 &
pnpm exec dotenv -e ../../.env -- pnpm exec next dev -p 4001 &

wait
