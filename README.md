# Remote Debugging iOS Safari on Windows and Linux

Using this project you can debug your websites and web applications running in iOS Safari from a PC running Windows or Linux.

It provides a free and up-to-date alternative to the discontinued [remotedebug-ios-webkit-adapter by RemoteDebug](https://github.com/RemoteDebug/remotedebug-ios-webkit-adapter) and is the spiritual successor to the abandoned [webkit-webinspector by Arty Gus](https://github.com/artygus/webkit-webinspector).

The setup scripts (`generate.sh` or `generate.ps1`) download the latest version of WebKit's built-in WebInspector and patch it to work with the WebSocket `ios-webkit-debug-proxy` provides and to be compatible with Chromium based browsers.

## Requirements for running

- [`ios-webkit-debug-proxy`](https://github.com/google/ios-webkit-debug-proxy)
  - On Windows, it will automatically be downloaded, but you must **also install iTunes for it to work**
  - For Linux, please follow the [installation instructions](https://github.com/google/ios-webkit-debug-proxy#linux).
- [Node.JS http-server](https://www.npmjs.com/package/http-server) **or** [Python](https://www.microsoft.com/store/productId/9P7QFQMJRFP7) **or** [PHP](https://www.php.net/)
  - If you have Python or PHP on your system, you don't need to change anything
  - If you have Node.JS on your system, just run `npm i -g http-server` and you're set.
- A Chromium based browser
  - like Google Chrome, Edge or Opera
- **or** WebKit based browser
  - like Epiphany/GNOME Web

## Requirements for setup

- `svn` (for `generate.sh`) or `git` (for `generate.ps1`) for downloading WebKit source code
  - On Windows, I suggest using [`git` for Windows](https://git-scm.com/download/win) in PowerShell
  - On Linux, I suggest installing `svn` from your package manager

## Instructions

### Setup

1. Clone this repository to your PC
2. On Windows, run `generate.ps1`. On Linux, run `generate.sh`.

This will result in the folder `WebKit` being created inside `src`. It contains the WebInspector files.

### Running

1. Plug your iOS device into your PC via USB
2. On the iOS device, go to `Settings->Safari->Advanced->Web Inspector` and enable it
3. Open the website you want to debug in Safari
4. On Windows, run `start.ps1`. On Linux, run `start.sh`.
5. Then open the Chromium or WebKit based browser of your choice with the following URL: [`http://localhost:8080/Main.html?ws=localhost:9222/devtools/page/1`](http://localhost:8080/Main.html?ws=localhost:9222/devtools/page/1)
6. You should be greeted with the WebInspector and can now debug to your heart's content.

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

If you want to see details about how this was made, you can read a detailed explanation in [`HOW_IT_WORKS.md`](https://github.com/HimbeersaftLP/ios-safari-remote-debug-kit/blob/master/HOW_IT_WORKS.md).

## Attribution

- This project was made possible thanks to
    - [webkit-webinspector](https://github.com/artygus/webkit-webinspector) for the idea
    - [ios-webkit-debug-proxy](https://github.com/google/ios-webkit-debug-proxy) for the ios-webkit-debug-proxy tool
    - [WebKit](https://github.com/WebKit/WebKit) for the WebInspector itself