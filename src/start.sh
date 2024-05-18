#!/usr/bin/env bash

set -euo pipefail

# https://stackoverflow.com/a/246128/
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Entering script directory $SCRIPT_DIR"
cd "$SCRIPT_DIR"

arg="${1:-}"
shift || true

if [ "$arg" != "-noServer" ] && [ ! -d "WebKit" ]; then
  echo "WebKit folder doesn't exists!"
  echo "Run 'generate.sh' to get the needed files."
  read -p "Press enter to close this window!"
  exit
fi

DEBUG_PROXY_EXE="ios_webkit_debug_proxy"

if [ "$arg" != "-noServer" ]; then
  echo "Running ios-webkit-debug-proxy..."
  $DEBUG_PROXY_EXE --no-frontend &

  # https://rimuhosting.com/knowledgebase/linux/misc/trapping-ctrl-c-in-bash
  trap ctrl_c INT

  function ctrl_c() {
    echo "Quitting ios-webkit-debug-proxy..."
    killall $DEBUG_PROXY_EXE
  }

  HOST="localhost"
  PORT="8080"
  DIR="WebKit/Source/WebInspectorUI/UserInterface/"

  echo ""
  echo "===================================================================================="
  echo "Will try to launch a web server on http://$HOST:$PORT"
  echo "You can then open http://$HOST:$PORT/Main.html?ws=localhost:9222/devtools/page/1"
  echo "in a Chromium or WebKit based browser to start debugging."
  echo "Press Ctrl+C to exit."
  echo "===================================================================================="
  echo ""

  echo "Searching web server"
  if command -v python3; then
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
      echo "Found Node.JS and NPM, but not http-server. You can install it using 'npm i -g http-server'"
      read -p "Press enter to close this window!"
      exit
    fi
  else
    echo "No compatible web server found!"
    echo "Please either install Python 3, PHP or Node.JS or run with the argument -noServer and use one of your choice."
    read -p "Press enter to close this window!"
    exit
  fi
else
  echo "Running without web server"
  echo "Running ios-webkit-debug-proxy..."
  $DEBUG_PROXY_EXE --no-frontend
fi
