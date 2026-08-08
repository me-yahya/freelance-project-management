#!/usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"
mkdir -p log tmp/pids

if [ -f tmp/pids/server.pid ]; then
  existing_pid="$(cat tmp/pids/server.pid)"
  if kill -0 "$existing_pid" 2>/dev/null; then
    echo "Freelance Manager is already running on PID $existing_pid."
    exit 0
  fi
  rm -f tmp/pids/server.pid
fi

bin/rails db:prepare
exec bin/rails server -b "${RAILS_BINDING:-127.0.0.1}" -p "${PORT:-3000}"
