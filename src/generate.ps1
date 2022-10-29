<#
.SYNOPSIS
  Download WebKit-WebInspector and apply patches.

.LINK
  Project repository: https://github.com/HimbeersaftLP/ios-safari-remote-debug-kit

.PARAMETER NoPause
  Do not pause before exiting script (for usage outside of launching the script from a GUI file explorer)

.PARAMETER FetchWebInspector
  Default: Download WebKit-WebInspector if it is not already downloaded, else exit.
  True:    Force download WebKit-WebInspector, even if it is already downloaded (for updating)
  False:   Never download WebKit-WebInspector, only apply patches to an already downloaded one

.PARAMETER iOSVersion
  Select iOS version for InspectorBackendCommands.js
#>
[CmdletBinding(PositionalBinding=$false)]
param (
    [Parameter()]
    [ValidateSet($null, $true, $false)]
    [object] $FetchWebInspector = $null,
    [Parameter()]
    [switch] $NoPause,
    [Parameter()]
    [string] $iOSVersion = ""
)

$ErrorActionPreference = "Stop"

Write-Output "Entering script directory $PSScriptRoot"
$previous_working_dir = Get-Location
cd $PSScriptRoot

if ($FetchWebInspector -eq $true -or $FetchWebInspector -eq $null) {
  if (Test-Path -Path WebKit) {
    if ($null -eq $FetchWebInspector) {
        Write-Output "WebKit folder already exists!"
        Write-Output 'Run with "-FetchWebInspector $true" to force an update.'
        cd $previous_working_dir
        if (-not $NoPause) {
          pause
        }
        exit 1
    } else {
      Write-Output "The folder $((Get-Item WebKit).FullName) and all its content will be erased"
      $confirm_response = ""
      while ($confirm_response -ne "y" -and $confirm_response -ne "n") {
        $confirm_response = Read-Host -Prompt "Confirm? (y/n)"
      }
      if ($confirm_response -eq "y") {
        Remove-Item -Recurse -Force WebKit
      } else {
        Write-Output "Cannot continue if the folder is not deleted! Exiting."
        cd $previous_working_dir
        exit 1
      }
    }
  }

  Write-Output "Downloading original WebInspector"
  git clone --depth 1 --filter="blob:none" --sparse "https://github.com/WebKit/WebKit.git"
  cd WebKit
  git sparse-checkout set Source/WebInspectorUI/UserInterface
  cd ..
}

Write-Output "Adding additional code"
cp injectedCode/* WebKit/Source/WebInspectorUI/UserInterface

Write-Output "Referencing additional code in HTML"
$path = 'WebKit/Source/WebInspectorUI/UserInterface/Main.html'
$replace = '<script src="Base/WebInspector.js"></script>'
$replaceWith = $replace + '<script src="InspectorFrontendHostStub.js"></script><link rel="stylesheet" href="AdditionalStyle.css">'
(Get-Content $path -Raw) -replace "$replace\r?\n",$replaceWith | Set-Content -NoNewline $path

Write-Output "Adding WebSocket init to Main.js"
$path = 'WebKit/Source/WebInspectorUI/UserInterface/Base/Main.js'
$replace = 'WI.loaded = function\(\)\r?\n{'
$replaceWith = 'WI.loaded = function() { WI._initializeWebSocketIfNeeded();'
(Get-Content $path -Raw) -replace $replace,$replaceWith | Set-Content -NoNewline $path

Write-Output "Replacing :matches with :is in CSS"
Get-ChildItem -Recurse -Include "*.css" "WebKit/Source/WebInspectorUI/UserInterface" | `
  Select-String ':matches' -List | `
  ForEach-Object {
    ($_ | Get-Content -Raw) -replace ':matches',':is' | Set-Content -NoNewline $_.Path
  }

Write-Output "Select iOS version for InspectorBackendCommands.js"
$protocolPath = 'WebKit/Source/WebInspectorUI/UserInterface/Protocol'
$legacyPath = "$protocolPath/Legacy/iOS"
$possibleVersions = (Get-ChildItem $legacyPath).Name
$latestVersion = (Get-ChildItem $legacyPath | Sort-Object Name -Descending)[0].Name
if ($iOSVersion -eq "") {
  $selectedVersion = $null
  while ((-not $possibleVersions.Contains($selectedVersion)) -and $selectedVersion -ne "") {
    $selectedVersion = Read-Host -Prompt "Choose iOS version (possible options: $($possibleVersions -join ", ")) Default: latest ($latestVersion)"
  }
} else {
  if ((-not $possibleVersions.Contains($iOSVersion)) -and $iOSVersion -ne "latest") {
    Write-Output "Invalid iOS version ($iOSVersion) provided! Allowed options: $($possibleVersions -join ", "), latest. Exiting."
    cd $previous_working_dir
    exit 1
  }
  if ($iOSVersion -eq "latest") {
    $selectedVersion = ""
  } else {
    $selectedVersion = $iOSVersion
  }
}
if ($selectedVersion -eq "") {
  $selectedVersion = $latestVersion
}
Write-Output "Copying InspectorBackendCommands.js for iOS $selectedVersion"
$backendCommandsFile = "$legacyPath/$selectedVersion/InspectorBackendCommands.js"
Write-Output "  -> Choosing file $backendCommandsFile"
cp $backendCommandsFile $protocolPath

cd $previous_working_dir

Write-Output "Finished!"

if (-not $NoPause) {
  pause
}