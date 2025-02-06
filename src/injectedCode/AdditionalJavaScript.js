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

// The default behavior of this event handler is to emulate a mouse click to the underlying select element.
// This does not work in Google Chrome anymore (https://stackoverflow.com/questions/430237/) so clicking it does nothing.
// We work around this in the AdditionalStyle.css by overlaying the select element transparently on top of the styled text.
// This code disables the default event handler, so that the select element can handle the click instead.
// Problem comes from here:
// https://github.com/WebKit/WebKit/blob/d21ca2c6897eafb4a8a19561b1d82f242240af9f/Source/WebInspectorUI/UserInterface/Views/MultipleScopeBarItem.js#L180-L202
if (WI?.MultipleScopeBarItem?.prototype?._handleMouseDown) {
    WI.MultipleScopeBarItem.prototype._handleMouseDown = () => {
        // Do nothing
    }
} else {
    console.error("WI.MultipleScopeBarItem.prototype._handleMouseDown not found");
}

// In Chrome, this number usually does not equal exactly, so we round down
// Function that is usually called is originally defined here:
// https://github.com/WebKit/WebKit/blob/4f5cad98ab8fe56792c6be7946615c041681ee2e/Source/WebInspectorUI/UserInterface/Base/Utilities.js#L529-L536
if (WI?.JavaScriptLogViewController?.prototype?.isScrolledToBottom)
{
    WI.JavaScriptLogViewController.prototype.isScrolledToBottom = () => {
        return this._scrollToBottomTimeout || (Math.floor(this._scrollElement.scrollTop + this._scrollElement.clientHeight) === this._scrollElement.scrollHeight);
    }
} else {
    console.error("WI.JavaScriptLogViewController.prototype.isScrolledToBottom not found");
}

// License header of modified code from Utilities.js:
/*
 * Copyright (C) 2013-2020 Apple Inc. All rights reserved.
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