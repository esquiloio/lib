// RGB LED Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
$(document).ready(function() {    
    function setRgb(red, green, blue) {
        // Update the RGB LED
        erpc("setLedColors", {red: red, green: green, blue: blue});
    }
    
    function rgbSliderChange() {
        var red   = redSlider.getValue();
        var green = greenSlider.getValue();
        var blue  = blueSlider.getValue();
        
        setRgb(red, green, blue);
    }

    function setBackgroundColor(red, green, blue) {
        $('body').css('background', 'rgb('+ red + ',' + green + ',' + blue + ')');
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

    function setRgbSliders(red, green, blue) {
        red   = Math.floor(red);
        green = Math.floor(green);
        blue  = Math.floor(blue);
        redSlider.setValue(red);
        greenSlider.setValue(green);
        blueSlider.setValue(blue);
               
        // Update the web page background
        setBackgroundColor(red, green, blue);
    }

    // Init to Esquilo blue
    setRgbSliders(0x03, 0x9d, 0xeb);
    rgbSliderChange();
    
    function randomColor() {
        return Math.floor(Math.random() * 255);
    }
    
    function setIsDiscoOn(isDiscoOn) {
        // Update disco mode on the Esquilo
        erpc("setIsDiscoOn", isDiscoOn);
    }

    $("[name='disco-switch']").bootstrapSwitch();
    $('input[name="disco-switch"]').on('switchChange.bootstrapSwitch', function(event, state) {
        if (state) {
            setIsDiscoOn(true);
            redSlider.disable();
            greenSlider.disable();
            blueSlider.disable();
        } else {
            setIsDiscoOn(false);
            redSlider.enable();
            greenSlider.enable();
            blueSlider.enable();
        }
    });
    
    var COLOR_UPDATE_MS = 75;
    function getLedColors() {
      erpc("getLedColors", null, function(result) {
        setRgbSliders(result.red, result.green, result.blue);  
	  	setTimeout(getLedColors, COLOR_UPDATE_MS);
      },
      function(text) {
        console.log("error: " + text);
	  	setTimeout(getLedColors, COLOR_UPDATE_MS);
      });
    }
    getLedColors();   
});