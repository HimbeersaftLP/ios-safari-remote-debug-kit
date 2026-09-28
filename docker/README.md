# Remotely Debug iOS

First and foremost, thank you to the developers that built the other packages that are collected here. This Dockerfile is based off of [dockerfile-remotedebug-ios-webkit-adapter](https://github.com/mugifly/dockerfile-remotedebug-ios-webkit-adapter) and is slightly updated to use the frontend from [ios-safari-remote-debug-kit](https://github.com/HimbeersaftLP/ios-safari-remote-debug-kit) instead of the deprecated [remotedebug-ios-webkit-adapter](https://github.com/RemoteDebug/remotedebug-ios-webkit-adapter). Also, thanks to `usbmuxd` and `imobiledevice` behind the scenes.

This Dockerfile will build and run a container that will allow you to debug Safari on iOS from your computer. The majority of the build steps will produce the `ios_webkit_debug_proxy` binary, which is the backend that will run in the container. The frontend is a web application that will be served by the container and can be accessed from your computer's browser. You can use the frontend to select the iOS device and Safari tab you want to debug, and the backend will proxy the connection to the iOS device. Alternately, use the backend directly with [iOS Safari Remote Debugger](https://ios-safari-debug.besties.house/), which may work better for some use cases.


## Requirements for Use

* iOS or iPad OS device
* Linux PC
* Google Chrome (possibly other browsers will work)
* `usbmuxd` daemon
    * Ubuntu / Debian: `$ sudo apt-get install -y usbmuxd`
    * Arch Linux: `$ sudo pacman -S usbmuxd`


## Quick Start

1. Enable the "Web Inspector" of Safari on iOS.
    * Open the "Settings" app
    * Select "Safari"
    * Scroll to the bottom and select "Advanced"
    * Enable "Web Inspector"
2. Open Safari and navigate to the page you want to debug.
3. Start `usbmuxd` daemon on Linux.
    * `sudo systemctl start usbmuxd`
4. Connect iOS (or iPad OS) device to Linux PC.
5. Trust your computer on the device.
6. Execute the following command on Linux.
    * `sudo ./start`
7. The output will list the iOS versions for the backend. If you want to debug iOS 15.9, you could see that 15.4 is in the list.
8. Execute the start command again with the iOS version you want to debug.
    * `sudo ./start 15.4`
9. This shows you a URL to start debugging.

At this point the debug proxy will be running and should be connected to your iOS device. From here, you can use the frontend directly by navigating to the URL provide, or you can use [iOS Safari Remote Debugger](https://ios-safari-debug.besties.house/).

Select the device and the tab to begin debugging.
