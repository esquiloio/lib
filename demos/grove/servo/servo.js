// Grove Servo Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
$(document).ready(function() {
    function positionSliderChange() {
        erpc("setPosition", positionSlider.getValue());
    }

    var positionSlider = $('#position-slider').slider()
        .on('slide', positionSliderChange)
        .data('slider');

    demoInit('servo');
    positionSliderChange();
});