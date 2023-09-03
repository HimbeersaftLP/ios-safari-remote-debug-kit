param (
    [switch]$noServer = $false
)

echo "Entering script directory $PSScriptRoot"
cd $PSScriptRoot

if (!$noServer -and !(Test-Path -Path WebKit)) {
    echo "WebKit folder doesn't exists!"
    echo "Run 'generate.sh' to get the needed files."
    pause
    exit
}

$debugProxyPath = "ios-webkit-debug-proxy"
$debugProxyExe = ".\" + $debugProxyPath + "\ios_webkit_debug_proxy.exe"
$shouldDownloadDebugProxy = $True
if (Test-Path -Path $debugProxyExe -PathType Leaf) {
    $debugProxyVersion = (& $debugProxyExe --version)
    if ($debugProxyVersion.Contains("ios_webkit_debug_proxy 1.8.8")) {
        echo "ios-webkit-debug-proxy is outdated, a newer version will be downloaded!"
        Rename-Item $debugProxyPath "ios-webkit-debug-proxy-1.8.8"
    } else {
        $shouldDownloadDebugProxy = $False
    }
}
if ($shouldDownloadDebugProxy) {
    echo "ios-webkit-debug-proxy not found or outdated, downloading it..."
    $debugProxyUrl = "https://github.com/google/ios-webkit-debug-proxy/releases/download/v1.9.0/ios-webkit-debug-proxy-1.9.0-win64-bin.zip"
    $debugProxyZip = "ios-webkit-debug-proxy.zip"
    Invoke-WebRequest $debugProxyUrl -OutFile $debugProxyZip
    Expand-Archive $debugProxyZip -DestinationPath $debugProxyPath
    rm $debugProxyZip
}
$debugProxyExe = Resolve-Path $debugProxyExe

$jobBlock = {
    param($cdPath)
    echo "Entering $cdPath"
    cd $cdPath

    $SRV_HOST = "localhost"
    $PORT = "8080"
    $DIR = "WebKit/Source/WebInspectorUI/UserInterface/"

    echo ""
    echo "===================================================================================="
    echo "Will try to launch a web server on http://$SRV_HOST`:$PORT"
    echo "You can then open http://$SRV_HOST`:$PORT/Main.html?ws=localhost:9222/devtools/page/1"
    echo "in a Chromium or WebKit based browser to start debugging."
    echo "Press Ctrl+C to exit."
    echo "===================================================================================="
    echo ""

    echo "Searching web server"
    if (Get-Command "python3.exe" -ErrorAction SilentlyContinue) {
        echo "Found Python 3, using it to serve the WebInspector"
        python3.exe -m http.server $PORT --bind $SRV_HOST --directory $DIR 2>&1 | Out-Null
    } elseif (Get-Command "php.exe" -ErrorAction SilentlyContinue) {
        echo "Found PHP, using it to serve the WebInspector"
        $HOST_PORT = "$SRV_HOST`:$PORT";
        php.exe -S $HOST_PORT -t $DIR 2>&1 | Out-Null
    } elseif ((Get-Command "node.exe" -ErrorAction SilentlyContinue) -and (Get-Command "npm" -ErrorAction SilentlyContinue)) {
        if (Get-Command "http-server.ps1" -ErrorAction SilentlyContinue) {
            echo "Found http-server, using it to serve the WebInspector"
            http-server.ps1 -a $SRV_HOST -p $PORT $DIR 2>&1 | Out-Null
        } else {
            echo "Found Node.JS and NPM, but not http-server. You can install it using 'npm i -g http-server'"
            pause
            exit
        }
    } else {
        echo "No compatible web server found!"
        echo "Please either install Python 3, PHP or Node.JS or run with the argument -noServer and use one of your choice."
        pause
        exit
    }
}


echo "Running ios-webkit-debug-proxy..."
$debugProxyProc = Start-Process $debugProxyExe -ArgumentList "--no-frontend" -PassThru

if (!$noServer) {
    $job = Start-Job -ScriptBlock $jobBlock -ArgumentList $PSScriptRoot
    try {
        # https://stackoverflow.com/a/1789948/
        [console]::TreatControlCAsInput = $true
        while (
            !$debugProxyProc.HasExited -and
            !($Host.UI.RawUI.KeyAvailable -and (3 -eq [int]$Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyUp,NoEcho").Character))
        ) {
            Start-Sleep -Milliseconds 200
            Receive-Job -Job $job
        }
    } finally {
        echo "Exiting, please wait..."

        Receive-Job -Job $job

        $job.StopJob()

        Remove-Job -Job $job

        if (!$debugProxyProc.HasExited) {
            echo "Quitting ios-webkit-debug-proxy..."
            $debugProxyProc.CloseMainWindow() | Out-Null
        }

        echo "Goodbye!"
    }
} else {
    echo "Running without web server"
}