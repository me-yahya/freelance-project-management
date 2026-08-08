#!/usr/bin/env bash
set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

if [ -f tmp/pids/server.pid ]; then
  existing_pid="$(cat tmp/pids/server.pid)"
  kill "$existing_pid" 2>/dev/null || true
  rm -f tmp/pids/server.pid
  echo "Stopped Freelance Manager PID $existing_pid."
else
  echo "No Rails server PID file found."
fi
