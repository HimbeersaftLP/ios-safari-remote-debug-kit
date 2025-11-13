#!/usr/bin/env bash

set -euo pipefail

# https://stackoverflow.com/a/246128/
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Entering script directory $SCRIPT_DIR"
cd "$SCRIPT_DIR"

arg="${1:-}"
shift || true

function fail_with_prompt() {
  for msg in "$@"; do
    echo "$msg"
  done
  read -p "Press enter to close this window!"
  exit 1
}

DEBUG_PROXY_PID=""

function cleanup() {
  if [ -n "$DEBUG_PROXY_PID" ] && kill -0 "$DEBUG_PROXY_PID" >/dev/null 2>&1; then
    echo "Quitting $DEBUG_PROXY_EXE..."
    kill "$DEBUG_PROXY_PID" >/dev/null 2>&1 || true
    wait "$DEBUG_PROXY_PID" 2>/dev/null || true
  fi
}

if [ "$arg" != "-noServer" ] && [ ! -d "WebKit" ]; then
  fail_with_prompt \
    "WebKit folder doesn't exists!" \
    "Run 'generate.sh' to get the needed files."
fi

DEBUG_PROXY_EXE="ios_webkit_debug_proxy"

if [ "$arg" != "-noServer" ]; then
  echo "Running $DEBUG_PROXY_EXE..."
  $DEBUG_PROXY_EXE --no-frontend &
  DEBUG_PROXY_PID=$!
  trap cleanup EXIT

  HOST="${WEBINSPECTOR_HOST:-localhost}"
  PORT="${WEBINSPECTOR_PORT:-8080}"
  DIR="WebKit/Source/WebInspectorUI/UserInterface/"

  echo ""
  echo "===================================================================================="
  echo "Will try to launch a web server on http://$HOST:$PORT"
  echo "You can then open http://$HOST:$PORT/ in a Chromium or WebKit based browser"
  echo "to pick a device + page, or open http://$HOST:$PORT/Main.html?ws=localhost:9222/devtools/page/1"
  echo "directly if you already know the page ID."
  echo "Press Ctrl+C to exit."
  echo "===================================================================================="
  echo ""

  echo "Searching web server"
  if command -v busybox >/dev/null 2>&1; then
    SERVE_HOST="$HOST"
    if ! [[ "$HOST" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
      SERVE_HOST=""
      if command -v getent >/dev/null 2>&1; then
        SERVE_HOST="$(getent ahostsv4 "$HOST" | awk 'NR==1 {print $1; exit}')"
      fi
      if [[ -z "$SERVE_HOST" ]]; then
        fail_with_prompt "Failed to resolve $HOST to an IP address for busybox httpd."
      fi
    fi
    echo "Resolved $HOST to $SERVE_HOST for busybox httpd"
    busybox httpd -v -f -p $SERVE_HOST:$PORT -h $DIR
  elif command -v python3; then
    echo "Found Python 3, using it to serve the WebInspector"
    python3 -m http.server $PORT --bind $HOST --directory $DIR
  elif command -v php; then
    echo "Found PHP, using it to serve the WebInspector"
    php -S $HOST:$PORT -t $DIR
  elif command -v node && command -v npm; then
    if command -v http-server; then
      echo "Found http-server, using it to serve the WebInspector"
      http-server -a $HOST -p $PORT $DIR
    else
      fail_with_prompt \
        "Found Node.JS and NPM, but not http-server. You can install it using 'npm i -g http-server'"
    fi
  else
    fail_with_prompt \
      "No compatible web server found!" \
      "Please either install Python 3, PHP or Node.JS or run with the argument -noServer and use one of your choice."
  fi
else
  echo "Running without web server"
  echo "Running ios-webkit-debug-proxy..."
  $DEBUG_PROXY_EXE --no-frontend
fi
