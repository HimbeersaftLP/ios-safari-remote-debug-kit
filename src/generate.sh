#!/bin/bash

set -euo pipefail

# https://stackoverflow.com/a/246128/
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "Entering script directory $SCRIPT_DIR"
cd $SCRIPT_DIR

if [ -d "WebKit" ]; then
  echo "WebKit folder already exists!"
  echo "Delete it if you want to update your installation."
  read -p "Press enter to close this window!"
  exit
fi

echo "Downloading original WebInspector"
git clone --depth 1 --filter="blob:none" --sparse "https://github.com/WebKit/WebKit.git"
cd WebKit
git sparse-checkout set Source/WebInspectorUI/UserInterface
cd ..

echo "Adding additional code"
cp injectedCode/* WebKit/Source/WebInspectorUI/UserInterface

echo "Referencing additional code in HTML"
sed -i -e ':a' -e 'N' -e '$!ba' \
  -e 's/<script src="Base\/WebInspector.js"><\/script>/<script src="Base\/WebInspector.js"><\/script><script src="InspectorFrontendHostStub.js"><\/script><link rel="stylesheet" href="AdditionalStyle.css">/g' \
  WebKit/Source/WebInspectorUI/UserInterface/Main.html

echo "Adding WebSocket init to Main.js"
sed -i -e ':a' -e 'N' -e '$!ba' \
  -e 's/WI.loaded = function()\r\{0,1\}\n{/WI.loaded = function() { WI._initializeWebSocketIfNeeded();/g' \
  WebKit/Source/WebInspectorUI/UserInterface/Base/Main.js

echo "Replacing :matches with :is in CSS"
grep -rlZ ':matches' WebKit/Source/WebInspectorUI/UserInterface --include='*.css' | xargs -0 sed -i 's/:matches/:is/g'

echo "Copying InspectorBackendCommands.js for the latest version"
protocolPath="WebKit/Source/WebInspectorUI/UserInterface/Protocol"
legacyPath="$protocolPath/Legacy/iOS"
versionFolder="$(ls -1 $legacyPath | sort | tail -n 1)"
backendCommandsFile="$legacyPath/$versionFolder/InspectorBackendCommands.js"
echo "  -> Choosing file $backendCommandsFile"
cp $backendCommandsFile $protocolPath

echo "Finished!"
read -p "Press enter to close this window!"