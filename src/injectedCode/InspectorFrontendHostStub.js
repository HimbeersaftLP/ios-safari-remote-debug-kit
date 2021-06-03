/*
 * Original license header for code from
 * https://github.com/WebKit/WebKit/blob/78ca9bb37991482f6d84fc2f534484412104bc73/Source/WebInspectorUI/UserInterface/Base/InspectorFrontendHostStub.js
 *
 * Copyright (C) 2009 Google Inc. All rights reserved.
 * Copyright (C) 2013 Seokju Kwon (seokju.kwon@gmail.com)
 * Copyright (C) 2013 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Original license header for code from
 * https://github.com/WebKit/WebKit/blob/b0e0508798feaab2ae41d31b8e6558f42c0b8dd8/Source/WebInspectorUI/UserInterface/Base/Main.js
 *
 * Copyright (C) 2013-2017 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

WI.InspectorFrontendHostStub = class InspectorFrontendHostStub {
    // Public

    initializeWebSocket(url) {
        var socket = new WebSocket(url);
        socket.addEventListener("open", socketReady.bind(this));

        function socketReady() {
            this._socket = socket;

            this._socket.addEventListener("message", function (message) {
                InspectorBackend.dispatch(message.data);
            });
            this._socket.addEventListener("error", function (error) {
                console.error(error);
            });

            this._sendPendingMessagesToBackendIfNeeded();
        }
    }

    bringToFront() {
        this._windowVisible = true;
    }

    closeWindow() {
        this._windowVisible = false;
    }

    userInterfaceLayoutDirection() {
        return "ltr";
    }

    requestSetDockSide(side) {
        InspectorFrontendAPI.setDockSide(side);
    }

    setAttachedWindowHeight(height) {}

    setAttachedWindowWidth(width) {}

    startWindowDrag() {}

    moveWindowBy(x, y) {}

    loaded() {}

    get localizedStringsURL() {
        return undefined;
    }

    get backendCommandsURL() {
        return undefined;
    }

    get inspectionLevel() {
        return 1;
    }

    inspectedURLChanged(title) {
        document.title = title;
    }

    copyText(text) {
        let textarea = document.createElement("textarea");
        textarea.textContent = text;
        document.body.appendChild(textarea);
        textarea.select();

        if (!document.execCommand("copy"))
            console.error("Could not copy to clipboard.");

        document.body.removeChild(textarea);
    }

    killText(text, shouldStartNewSequence) {}

    save(url, content, base64Encoded, forceSaveAs) {}

    sendMessageToBackend(message) {
        if (!this._socket) {
            if (!this._pendingMessages) this._pendingMessages = [];
            this._pendingMessages.push(message);
            return;
        }

        this._sendPendingMessagesToBackendIfNeeded();

        this._socket.send(message);
    }

    get platform() {
        return (navigator.platform.match(/mac|win|linux/i) || ["other"])[0].toLowerCase();
    }

    beep() {}

    showContextMenu(event, menuObject) {
        new WI.SoftContextMenu(menuObject).show(event);
    }

    unbufferedLog() {
        console.log.apply(console, arguments);
    }

    setZoomFactor(zoom) {}

    zoomFactor() {
        return 1
    }

    isExperimentalBuild() {
        return false;
    }

    get debuggableInfo() {
        return {
            debuggableType: "web-page",
            targetPlatformName: "Unknown",
            targetBuildVersion: "Unknown",
            targetProductVersion: "Unknown",
            targetIsSimulator: false
        }
    }

    setForcedAppearance(appearance) {}

    setAllowsInspectingInspector(allow) {}

    supportsDockSide(dockSideString) {}

    setSheetRect(x, y, width, height) {}

    get isRemote() {
        return true;
    }

    // Private

    _sendPendingMessagesToBackendIfNeeded() {
        if (!this._pendingMessages) return;

        for (var i = 0; i < this._pendingMessages.length; ++i) this._socket.send(this._pendingMessages[i]);

        delete this._pendingMessages;
    }
};

if (!window.InspectorFrontendHost) {
    InspectorFrontendHost = new WI.InspectorFrontendHostStub();

    WI.dontLocalizeUserInterface = true;

    WI._initializeWebSocketIfNeeded = function () {
        if (!InspectorFrontendHost.initializeWebSocket)
            return;

        var queryParams = parseQueryString(window.location.search.substring(1));

        if ("ws" in queryParams)
            var url = "ws://" + queryParams.ws;
        else if ("page" in queryParams) {
            var page = queryParams.page;
            var host = "host" in queryParams ? queryParams.host : window.location.host;
            var url = "ws://" + host + "/devtools/page/" + page;
        }

        if (!url)
            return;

        InspectorFrontendHost.initializeWebSocket(url);
    }

    // Make it not crash on Chrome when trying to render windows with shadow
    // Ideally you'd use a proper polyfill
    // https://stackoverflow.com/a/3433039/
    if (!Document.prototype.getCSSCanvasContext) {
        Document.prototype.getCSSCanvasContext = function (contextType, identifier, width, height) {
            const canvas = document.createElement("canvas");
            canvas.width = width;
            canvas.height = height;
            return canvas.getContext(contextType);
        };
    }

    // Make it not crash on Chrome when trying to click an Element
    // https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleDeclaration/getPropertyCSSValue
    if (!CSSStyleDeclaration.prototype.getPropertyCSSValue) {
        window.CSSPrimitiveValue = {};
        window.CSSPrimitiveValue.CSS_PX = "px";

        CSSStyleDeclaration.prototype.getPropertyCSSValue = function (property) {
            const _this = this;
            return {
                getFloatValue: function (unit) {
                    if (unit === CSSPrimitiveValue.CSS_PX) {
                        const value = Number(_this.getPropertyValue(property).replace("px", ""));
                        return value;
                    } else {
                        throw "Unit not implemented!";
                    }
                }
            }
        }
    }
}