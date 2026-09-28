#!/bin/bash

showAvailableVersions() {
    echo "Available versions:"
    for version in "${possibleVersions[@]}"; do
        echo "  $version"
    done
}

path="/opt/ios-safari-remote-debug-kit/src/WebKit/Source/WebInspectorUI/UserInterface/Protocol/Legacy/iOS"
read -ra possibleVersions < <( cd "$path" && find . -type f | cut -d '/' -f 2 | sort -h | tr "\n" " ")

if [[ -z "$1" ]]; then
    echo "Must select iOS version for InspectorBackendCommands.js by passing the version number as an argument."
    echo ""
    showAvailableVersions
    exit 1
fi

found=false
for version in "${possibleVersions[@]}"; do
    if [[ "$1" == "$version" ]]; then
        found=true
    fi
done

if ! $found; then
    echo "Invalid iOS version provided: $1"
    echo ""
    showAvailableVersions
    exit 1
fi

echo "Using iOS version $1"

cp "$path/$1/InspectorBackendCommands.js" "$path/../../"

# Start the proxy
echo "START PROXY"
ios_webkit_debug_proxy -f /opt/ios-safari-remote-debug-kit/src/WebKit/Source/WebInspectorUI/UserInterface/Main.html &

# Wait a bit and then show the host and port for people to start debugging.
sleep 1
echo ""
echo ""
echo "To start debugging, point your browser to"
echo "    http://localhost:9221/"

# Wait for any backgrounded process to exit
wait -n

# Exit with status of process that exited first
exit $?
