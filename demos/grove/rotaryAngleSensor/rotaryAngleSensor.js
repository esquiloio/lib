// Grove Rotary Angle Sensor Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
$(document).ready(function() {
    function setBackgroundColor(red, green, blue) {
        $('body').css('background', 'rgb('+ red + ',' + green + ',' + blue + ')');
    }
    
    var BRIGHTNESS_UPDATE_MS = 100;
    function getBrightness() {
        erpc("getBrightness", null, function(result) {
                var brightness = result;
            	console.log('brightness', brightness);
                var r = Math.round((0x3 * brightness) / 100);
           		var g = Math.round((0x9d * brightness) / 100);
            	var b = Math.round((0xeb * brightness) / 100);
            	setBackgroundColor(r, g, b);
            	setTimeout(getBrightness, BRIGHTNESS_UPDATE_MS);
            },
            function(text) {
                console.log("error: " + text);
                setTimeout(getBrightness, BRIGHTNESS_UPDATE_MS);
            });
    }
    getBrightness();

    demoInit('rotaryAngleSensor');
});