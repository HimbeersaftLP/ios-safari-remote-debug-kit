# Remote Debugging iOS Safari on Windows and Linux

Using this project you can debug your websites and web applications running in iOS Safari from a PC running Windows or Linux.

It provides a free and up-to-date alternative to the discontinued [remotedebug-ios-webkit-adapter by RemoteDebug](https://github.com/RemoteDebug/remotedebug-ios-webkit-adapter) and is the spiritual successor to the abandoned [webkit-webinspector by Arty Gus](https://github.com/artygus/webkit-webinspector). It is a free and open source alternative to inspect.dev.

The setup scripts (`generate.sh` or `generate.ps1`) download the latest version of WebKit's built-in WebInspector and patch it to work with the WebSocket `ios-webkit-debug-proxy` provides and to be compatible with Chromium based browsers.

**If you are looking for a more modern, self-contained tool built in Go**, check out [Hazel's ios-safari-remote-debug](https://git.gay/besties/ios-safari-remote-debug).

## Requirements for running

- [`ios-webkit-debug-proxy`](https://github.com/google/ios-webkit-debug-proxy)
  - On Windows, it will automatically be downloaded, but you must **also install and trust the device in iTunes for it to work**
  - For Linux, please follow the [installation instructions](https://github.com/google/ios-webkit-debug-proxy#linux).
- [Node.JS http-server](https://www.npmjs.com/package/http-server) **or** [Python](https://www.microsoft.com/store/productId/9P7QFQMJRFP7) **or** [PHP](https://www.php.net/)
  - If you have Python or PHP on your system, you don't need to change anything
  - If you have Node.JS on your system, just run `npm i -g http-server` and you're set.
- A Chromium based browser
  - like Google Chrome, Edge or Opera
- **or** WebKit based browser
  - like Epiphany/GNOME Web

## Requirements for setup

- `git` (required by `generate.sh` or `generate.ps1`) for downloading WebKit source code
  - On Windows, I suggest using [`git` for Windows](https://git-scm.com/download/win) in PowerShell
  - On Linux, I suggest installing `git` from your package manager

## Instructions

### Setup

1. Clone this repository to your PC
2. On Windows, run `generate.ps1`. On Linux, run `generate.sh`.

This will result in the folder `WebKit` being created inside `src`. It contains the WebInspector files.

### Running

1. Plug your iOS device into your PC via USB
2. On Windows, open iTunes and mark the iOS device as trusted (pop-up asks for confirmation the first time you connect a new device)
3. On the iOS device, confirm that you trust the connection if asked
4. Go to `Settings->Safari->Advanced->Web Inspector` and enable it
5. Open the website you want to debug in Safari
6. On Windows, run `start.ps1`. On Linux, run `start.sh`. Make sure your iOS device's screen is unlocked.
7. The `ios-webkit-debug-proxy` will show your iOS device's name as connected.
8. Then open the Chromium or WebKit based browser of your choice with the following URL: [`http://localhost:8080/Main.html?ws=localhost:9222/devtools/page/1`](http://localhost:8080/Main.html?ws=localhost:9222/devtools/page/1)
    - If you have mutliple pages open or extensions installed, refer to [http://localhost:9222/](http://localhost:9222/) for the page number that is at the end of the URL
9. You should be greeted with the WebInspector and can now debug to your heart's content.

### Troubleshooting

- If you get an error like `Uncaught (in promise) Error: 'Browser' domain was not found` from `Connection.js:162` you are trying to inspect a page that is not inspectable  (this could be caused by having Safari extensions installed). Refer to [http://localhost:9222/](http://localhost:9222/) for the available pages and put the correct one at the end of the URL (for example [`http://localhost:8080/Main.html?ws=localhost:9222/devtools/page/2`](http://localhost:8080/Main.html?ws=localhost:9222/devtools/page/2)) for inspecting the second page.
- In case your inspector window stays empty, open the dev tools of your local browser to check the console for errors.
  - If you get an error like `WebSocket connection to 'ws://localhost:9222/devtools/page/1' failed:` from `InspectorFrontendHostStub.js:68`, try unplugging your device and plugging it back in while the site you want to debug is open in Safari. Once you see the ios-webkit-debug-proxy console window display a message like `Connected :9222 to Himbeers iPad (...)`, refresh the inspector page inside your browser (do not use the refresh button on the inspector page, refresh the entire site from your browser).

### Exiting

#### Windows

- Two windows will open. One manages the web server and the other one is `ios-webkit-debug-proxy`.
- To exit, close the `ios-webkit-debug-proxy` window, the other one will close automatically
  - Alternatively you can also press Ctrl+C in the web server window

#### Linux

- Press Ctrl+C in the terminal window to exit

## Known Issues

- "Events" on the "Timelines" tab don't work
- Canvas content doesn't show on the "Graphics" tab
- Minor style glitches due to Webkit vs. Chromium differences

## Notes

If you want to see details about how this was made, you can read a detailed explanation in [`HOW_IT_WORKS.md`](https://github.com/HimbeersaftLP/ios-safari-remote-debug-kit/blob/master/HOW_IT_WORKS.md) (note that this document only describes how the very first version of this tool was created and might not be completely up-to-date).

## Attribution

- This project was made possible thanks to
  - [webkit-webinspector](https://github.com/artygus/webkit-webinspector) for the idea
  - [ios-webkit-debug-proxy](https://github.com/google/ios-webkit-debug-proxy) for the ios-webkit-debug-proxy tool
  - [WebKit](https://github.com/WebKit/WebKit) for the WebInspector itself
