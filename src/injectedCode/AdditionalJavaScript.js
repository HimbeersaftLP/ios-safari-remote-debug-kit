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