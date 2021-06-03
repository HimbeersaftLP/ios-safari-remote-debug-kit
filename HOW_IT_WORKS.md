# How this was made

Here's how I managed to get a local copy of the WebKit WebInspector working with [Google's ios-webkit-debug-proxy](https://github.com/google/ios-webkit-debug-proxy) on iOS 14.6 in 2021.

This work is inspired by [Arty Gus's webkit-webinspector](https://github.com/artygus/webkit-webinspector) which seems to have been abandoned.

## Steps

Note: All terminal commands shown work in both `bash` and `PowerShell` unless otherwise noted.

### Setting up our workspace

#### Requirements

- [`ios-webkit-debug-proxy`](https://github.com/google/ios-webkit-debug-proxy)
  - On Windows we must also install iTunes
- `svn` or `git` for downloading WebKit source code
  - On Windows, I suggest either using [`git` for Windows](https://git-scm.com/download/win) or `svn` in [WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
- A Chromium based browser (like Google Chrome, Edge or Opera) or WebKit based browser (like Epiphany/GNOME Web)

#### Folder

First we create a directory to work in and enter it:

```bash
mkdir ios-remote-debugging
cd ios-remote-debugging
```

### Getting the WebInspector files

The most important part is the WebInspector itself. It can be found in the source code of WebKit.

To download it we can either use the following `svn` command (thank you [Arty Gus](https://github.com/artygus/webkit-webinspector#update)):

```bash
svn checkout https://svn.webkit.org/repository/webkit/trunk/Source/WebInspectorUI/UserInterface WebKit/Source/WebInspectorUI/UserInterface
```

or this `git` command (thank you [Stack Overflow](https://stackoverflow.com/a/52269934/)):

```bash
git clone --depth 1 --filter=blob:none --sparse https://github.com/WebKit/WebKit.git
cd WebKit
git sparse-checkout set Source/WebInspectorUI/UserInterface
cd ..
```

We should now have a folder called `WebKit` with the subfolder structure `Source/WebInspectorUI/UserInterface` in which we will find the needed files.

### Adding some ancient files to the mix

The WebSocket protocol offered by `ios-webkit-debug-proxy` isn't supported in newer versions of the WebKit WebInspector anymore. Thanks to the power of version control however we can add that support back in.

We need two different things, the code that initialises the connection that goes into the `Main.js` file and the `InspectorFrontEndHostStub.js` files, which is what replaces the `InspectorFrontEndHost` that would normally be created by the method that replaced WebSockets.

Both of those things were removed in commit [b65bda90170215a72fcdf2a1bb80ffcc4aa15e73](https://github.com/WebKit/WebKit/commit/b65bda90170215a72fcdf2a1bb80ffcc4aa15e73).

The Main.js part can be found [here](https://github.com/WebKit/WebKit/commit/b65bda90170215a72fcdf2a1bb80ffcc4aa15e73#diff-eed4643598fbdc21c2b735d2587cd30f597a8a689ec1fec55673fb40ce2a78cd) and the InspectorFrontEndHostStub.js file [here](https://github.com/WebKit/WebKit/blob/78ca9bb37991482f6d84fc2f534484412104bc73/Source/WebInspectorUI/UserInterface/Base/InspectorFrontendHostStub.js).

I downloaded `InspectorFrontEndHostStub.js` into the `UserInterface` folder and kept a browser tab with the Main.js part open.

### Making some changes

#### JavaScript

Since the `InspectorFrontEndHostStub.js` file is pretty old by now, it's missing some of the properties and methods that have been added since. I also rewrote it to use a `class` instead of the old fashioned way it was written in before.

- The name `WebInspector` has also been shorted to `WI`.
- The missing properties and methods have been added. I used [`InspectorFrontendHost.cpp`](https://github.com/WebKit/webkit/blob/main/Source/WebCore/inspector/InspectorFrontendHost.cpp) and the WebInspector inspected with another WebInspector in Epiphany (a WebKit based browser) as references.
- I added `_initializeWebSocketIfNeeded` into the `WI` object.
- I added a very primitive polyfill for `getPropertyCSSValue` and a dummy function for `getCSSCanvasContext`. These are WebKit specific legacy functions that are still used by the WebInspector. These changes are nedded to make it work in Chromium based browsers. With a bit more work one could probably also get it to work in Firefox.

Lastly, `WI._initializeWebSocketIfNeeded()` must be called when the WebInspector loads, so we add that call to the top of the `WI.loaded` function like so:

```js
WI.loaded = function()
{
    WI._initializeWebSocketIfNeeded();
```

The following `sed` command does that automatically:

```bash
sed -i -e ':a' -e 'N' -e '$!ba' -e 's/WI.loaded = function()\r\{0,1\}\n{/WI.loaded = function() { WI._initializeWebSocketIfNeeded();/g' WebKit/Source/WebInspectorUI/UserInterface/Base/Main.js
```

or the `PowerShell` variant:

```ps
$path = 'WebKit/Source/WebInspectorUI/UserInterface/Base/Main.js'
$replace = 'WI.loaded = function\(\)\r?\n{'
$replaceWith = 'WI.loaded = function() { WI._initializeWebSocketIfNeeded();'
(Get-Content $path -Raw) -replace $replace,$replaceWith | Set-Content $path
```

#### CSS

Just like with the JavaScript, the CSS also makes use of some WebKit specific features and quirks. So I wrote a little css file that fixes some of them. In the `UserInterface` folder I created a new file named `AdditionalStyles.css`.

- I gave the navigation bar items (the warning and error icons) a fixed with of 16px, before they would be way too large due to differences in svg handling.
- I gave the `.popover` class a fixed background color, because previously the background was created using `getCSSCanvasContext()` which doesn't work in non-WebKit browsers.

The WebInspector CSS also makes a lot of use of the `:matches()` pseudo-class. `:matches()` was the WebKit-specific name for the now standardised `:is()`.

We can use a quick string replacement to update them by running this command in the `UserInterface` folder:

```bash
grep -rlZ ':matches' . --include='*.css' | xargs -0 sed -i 's/:matches/:is/g'
```

or the `PowerShell` variant:

```ps
Get-ChildItem -Recurse -Include "*.css" | Select-String ':matches' -List | ForEach-Object { ($_ | Get-Content -Raw) -replace ':matches',':is' | Set-Content $_.Path }
```

#### HTML

Of course we need to load our JS and CSS file. To do that, we add

```html
<script src="InspectorFrontendHostStub.js"></script>
<link rel="stylesheet" href="AdditionalStyle.css">
```

to the `Main.html` file right after `<script src="Base/WebInspector.js"></script>`

The following `sed` command does that automatically:

```bash
sed -i -e ':a' -e 'N' -e '$!ba' -e 's/<script src="Base\/WebInspector.js"><\/script>/<script src="Base\/WebInspector.js"><\/script><script src="InspectorFrontendHostStub.js"><\/script><link rel="sty
lesheet" href="AdditionalStyle.css">/g' WebKit/Source/WebInspectorUI/UserInterface/Main.html
```

or the `PowerShell` variant:

```ps
$path = 'WebKit/Source/WebInspectorUI/UserInterface/Main.html'
$replace = '<script src="Base/WebInspector.js"></script>'
$replaceWith = $replace + '<script src="InspectorFrontendHostStub.js"></script><link rel="stylesheet" href="AdditionalStyle.css">'
(Get-Content $path -Raw) -replace $replace,$replaceWith | Set-Content $path
```

### Selecting the version

In the `WebKit/Source/WebInspectorUI/UserInterface/Protocol/Legacy` folder we can find folders with `InspectorBackendCommands.js` files for different versions of iOS. We copy the `InspectorBackendCommands.js` for the one that is lower than or equal to ours (e.g. if we are running 14.6, copy 14.5; if we are running 14.5, copy 14.5) into the `WebKit/Source/WebInspectorUI/UserInterface/Protocol` folder.

For example:

```bash
cp WebKit/Source/WebInspectorUI/UserInterface/Protocol/Legacy/14.5/InspectorBackendCommands.js WebKit/Source/WebInspectorUI/UserInterface/Protocol/
```

Bash script for automatically copying the latest version:

```bash
protocolPath="WebKit/Source/WebInspectorUI/UserInterface/Protocol"
legacyPath="$protocolPath/Legacy"
versionFolder="$(ls -1 $legacyPath | sort | tail -n 1)"
backendCommandsFile="$legacyPath/$versionFolder/InspectorBackendCommands.js"
cp $backendCommandsFile $protocolPath
```

PowerShell equivalent:

```ps
$protocolPath = 'WebKit/Source/WebInspectorUI/UserInterface/Protocol'
$legacyPath = "$protocolPath/Legacy"
$versionFolder = (Get-ChildItem $legacyPath | Sort-Object Name -Descending)[0]
$backendCommandsFile = "$legacyPath/$versionFolder/InspectorBackendCommands.js"
cp $backendCommandsFile $protocolPath
```

### Running it

Now that all the needed changes are done, we can test it.

On our iOS device, we go to `Settings->Safari->Advanced->Web Inspector` and enable it. Then open a webpage in Safari.

After downloading `ios-webkit-debug-proxy` and installing iTunes, we plug in our iOS device via USB and launch `ios-webkit-debug-proxy` without a frontend using the `-F` argument. For example on Windows: `.\ios-webkit-debug-proxy-1.8.8-win64-bin\ios_webkit_debug_proxy.exe -F`.

The output should then look something like this:

```text
Listing devices on :9221
Connected :9222 to Himbeers iPad (00000000-0000000000000000)
```

To view the inspector, we need to open it in our browser. However opening the `Main.html` file directly would give us origin errors because "file:" URLs are treated with extra security.

So we need to run a web server that serves WebInspector for us. Any static file server will work.

For example:

- Node.JS: The `http-server` npm package (adds the terminal command `http-server`)
- Python 3:  `python3 -m http.server 8080`
- PHP: `php -S localhost:8080`

Whichever server we choose, we run it from the `WebKit/Source/WebInspectorUI/UserInterface` folder. Then open our Chromium or WebKit based browser with the following URL:

[`http://localhost:8080/Main.html?ws=localhost:9222/devtools/page/1`](http://localhost:8080/Main.html?ws=localhost:9222/devtools/page/1)

(if `ios_webkit_debug_proxy` gave a port different from `9222` for the device we want to debug, that port should be used instead, of course)

We should now be greeted with the WebInspector and can debug to our heart's content.
