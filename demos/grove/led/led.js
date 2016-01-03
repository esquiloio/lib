// Grove LED Socket Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
$(document).ready(function() {    
    function setSpeed(speed) {
        var breathDelay = 10 - Math.round((speed * 10) / 255);
        console.log("breath delay: ", breathDelay);
        erpc("setBreathDelay", breathDelay);
    }
    
    function speedSliderChange() {
        var speed   = speedSlider.getValue();
        console.log("speed: ", speed);
        setSpeed(speed);
    }

    function setBackgroundColor(red, green, blue) {
        $('body').css('background', 'rgb('+ red + ',' + green + ',' + blue + ')');
    }

    var speedSlider = $('#speed-slider').slider()
        .on('slide', speedSliderChange)
        .data('slider');
    
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

    demoInit('led');
});