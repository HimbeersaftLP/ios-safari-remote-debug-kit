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

if (!window.Float16Array) {
    window.Float16Array = function() {
        console.error("Float16Array not implemented");
    }
}