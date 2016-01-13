// Grove RGB LCD Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
$(document).ready(function() {
    $('#power').bootstrapSwitch();
    $('#power').on('switchChange.bootstrapSwitch', function(event, state) {
        erpc("displayPower", state);
    });

    function setRgb(red, green, blue) {
        // Update the RGB LED
        erpc("setLedColors", {red: red, green: green, blue: blue});
        $('body').css('background', 'rgb('+ red + ',' + green + ',' + blue + ')');
    }

    function rgbSliderChange() {
        var red   = redSlider.getValue();
        var green = greenSlider.getValue();
        var blue  = blueSlider.getValue();

        setRgb(red, green, blue);
    }

    var redSlider = $('#R').slider()
        .on('slide', rgbSliderChange)
        .data('slider');
    var greenSlider = $('#G').slider()
        .on('slide', rgbSliderChange)
        .data('slider');
    var blueSlider = $('#B').slider()
        .on('slide', rgbSliderChange)
        .data('slider');

    $('#text').change(function(){
        erpc("displayText", $('#text').val());
    });

    $('#update').click(function() {
        erpc("displayText", $('#text').val());
    });

    demoInit('rgbLcd');
});