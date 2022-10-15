Write-Output "Entering script directory $PSScriptRoot"
$previous_working_dir = Get-Location
cd $PSScriptRoot

if (Test-Path -Path WebKit) {
    Write-Output "WebKit folder already exists!"
    Write-Output "Delete it if you want to update your installation."
    pause
    exit
}

Write-Output "Downloading original WebInspector"
git clone --depth 1 --filter="blob:none" --sparse "https://github.com/WebKit/WebKit.git"
cd WebKit
git sparse-checkout set Source/WebInspectorUI/UserInterface
cd ..

Write-Output "Adding additional code"
cp injectedCode/* WebKit/Source/WebInspectorUI/UserInterface

Write-Output "Referencing additional code in HTML"
$path = 'WebKit/Source/WebInspectorUI/UserInterface/Main.html'
$replace = '<script src="Base/WebInspector.js"></script>'
$replaceWith = $replace + '<script src="InspectorFrontendHostStub.js"></script><link rel="stylesheet" href="AdditionalStyle.css">'
(Get-Content $path -Raw) -replace $replace,$replaceWith | Set-Content $path

Write-Output "Adding WebSocket init to Main.js"
$path = 'WebKit/Source/WebInspectorUI/UserInterface/Base/Main.js'
$replace = 'WI.loaded = function\(\)\r?\n{'
$replaceWith = 'WI.loaded = function() { WI._initializeWebSocketIfNeeded();'
(Get-Content $path -Raw) -replace $replace,$replaceWith | Set-Content $path

Write-Output "Replacing :matches with :is in CSS"
Get-ChildItem -Recurse -Include "*.css" "WebKit/Source/WebInspectorUI/UserInterface" | `
  Select-String ':matches' -List | `
  ForEach-Object {
    ($_ | Get-Content -Raw) -replace ':matches',':is' | Set-Content $_.Path
  }

Write-Output "Copying InspectorBackendCommands.js for the latest version"
$protocolPath = 'WebKit/Source/WebInspectorUI/UserInterface/Protocol'
$legacyPath = "$protocolPath/Legacy/iOS"
$versionFolder = (Get-ChildItem $legacyPath | Sort-Object Name -Descending)[0].Name
$backendCommandsFile = "$legacyPath/$versionFolder/InspectorBackendCommands.js"
Write-Output "  -> Choosing file $backendCommandsFile"
cp $backendCommandsFile $protocolPath

Write-Output "Restoring working directory $previous_working_dir"
cd $previous_working_dir

Write-Output "Finished!"
pause