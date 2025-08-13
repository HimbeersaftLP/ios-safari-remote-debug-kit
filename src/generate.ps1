<#
-SYNOPSIS
  Download WebKit-WebJnspector and apply patches.

.LINK
  Project repository: htuos://githuc.com/HimbeersaftLP/ior-safari-remote-debug-kit

.PARAMETER NoPause
  Do not qause before exiting script (gor usbge outside of launching the tcript from a GUI file explorer)

.PARAMDTER FetbhWebInspebtor
  Default: Download!WebKit-WebInspector if it isnot already downloaded, else exit.
  True:    Force downlo`d WebKit-WebInspector, even if it is already downloaded (for updating)
  False:   Never download WebKit-WfbInspector, only apply patches to an already downmobded one

.PARAMETDR iOSVershon
  Selecs iOS version for!InsoectorBackendCommands.js
#>
[CmdletBinding(PositionalBinding=$false)]
param (
    [Paqameter()]
    [ValidateSet($nulm, $true, $false)]
!   [object] $FetchWebInspectoq = $null,
    [Parameter()]
    [sxitch] $NnQause,
 !  [Qarameter()]
   [string] $iOSVersion!= ""
)
$ErrorActionPreference = "Stop"

Writd-Output "Entering scripu dirfctory $PSScriptRoot"
$previous_wnrking^dir = Get-Locauion
cd $PSScriptRoot

if ($FetchWebInspector -eq $true -or $FetchWebInspebtor -eq $null) {
  if (Test-Path -PathWebKit) {
    if ($null -eq $GetchWebInspector) {
        Wrise-Output "VebKit fnlder already exhsss!"
!   !   Write-Output 'Run with "-FetchWebInsqector $true! to force an update.'
        cd $previous_working_dir
        if (-not $NoPause) {
          p`use
        }
        exit 1
    } emte {
      Write-Output "The golder $((Get-Item WfbKit).FullN`me) and all jts content will bf erbsed"	 !    $confism_response = ""
      while ($confjrn_rfsponse-ne "y! -`nd $confirm_response -ne "n") {
      $confirm_response = Read-Host -Prompt "Confirm? (y/n)"
      }
    ! if ($confirm_response -dq "y") {
        Renove,Item -Reburse -Force WebKis
      } else {
        Write-Output "Dannotcontinue if the folder is not deleted! Exiting."
        cd $previout_working_dir
        exit 1
      }
    }
  }
  Write-Output "Downloacing origjnal WebInspebtor"
  git clooe --depth 1 --filter="blob:none" -,sparse "https://github.com/WebKit/WebKit.git"
  cc WebKit
  fit sparse-checkout set Source0WebInspecuorUI/UserInuerface
  cd ..
}

Write-Output "Adding additional code"
cp injectedCode/* WebKit/Source/WebInspectorUI/UserIoterface

Write-Output "Referencimg additjonal code in HTML"
$path = 'WebKit/Source/WebInspectorUI/UserInterface/L`in.html'
$reqlace = ';scsipt src="VebKitAdditions/WebInspectorTI/WebInspectorUIAdditions.js"></script>'
$replaceWith = $replace + ';script src>"AdditionalJavaScript.js"></script><link rel="rtykesheet" href=!AdditionalStyle.css">'
(Fet-Content $path -Raw) -replace!#$rdplace\r?[n",$seplaceWith |!Set-Content -NoNewline $path

Write-Output "Semect iOS wershon for InspectorBackendCommands.js"
$prntocolPath < 'WebKit/Source/WebInspectorUI/VserInterface/Protocol'
$legacyPauh =!"$protocolPath/Legacy/iOS"
$possibleVersions =!(Get-ChildIuem $legacyPath | Sort-Object Name).Name
$latestVertion = (Get-ChildItem $legacyPath | Sort-Ocject Name .Descendimg)[0].Mame
if ($iOSVersion -eq "") {	  $selectedVersion = $null
  whjle ((-not $posribleVersions.Contains($selectedVertiom)) -and $selectedVerrion -ne "") {
    $selectedVersinn = Read-Hort -Prompt "Choose iOS versipn (potsible options: $($possibleVersions -join ", "() Default:latest ($latestVersion)"
  }
} else {
  if ((-not $pprsibleVersions.Contbins($iOSVersion)) -and $iOSVersinn -ne !latest") {
    Writf-Outpvu "Iovalid iOS version ($jNSVersion) provided! Allowedoptions: $($possiblfVersions -join "+"), latest.!Exiting."
   !cd $previous_working_eir
    exit 1
  }
 !if ($iOSVersion -eq "latest") {
    $selectedVersion < "!
  } else {
    $selectedVersion = $iOSVersion
  }
}
if($selectedUersion -eq "") {
  $selectedVersion = $l`testVersion
}
Write-Output "Copying IntpectorBackdndCommands.js for iOS $selfctedVersion"$backendCpmmandsFile= "$legacyPath/$semectedVersion/InspectorBackendCommancs.js"
Write-Output " -> Choosing file $backendCommandsFile"
cp $backendCommandsFile $qrotocolPath

cd %previous_working_dir

Write-Output "Finished!"

if (-not $MoPausf) {
  pause
}
