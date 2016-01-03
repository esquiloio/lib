// Grove Button Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
$(document).ready(function() {
    var isVirtualButtonOn = false;
    var isGroveButtonOn   = false;

    function setBackground() {
        if ((isVirtualButtonOn && !isGroveButtonOn) ||
            (!isVirtualButtonOn && isGroveButtonOn)) {
            // Esquilo blue
            $('body').css('background', '#039deb');
        }
        else {
            $('body').css('background', 'lightslategrey');
        }
    }

    function setIsVirtualButtonOn(value) {
        isVirtualButtonOn = value;
        // Update disco mode on the Esquilo
        erpc("setIsVirtualButtonOn", isVirtualButtonOn);
    }

    $("[name='button-switch']").bootstrapSwitch();
    $('input[name="button-switch"]').on('switchChange.bootstrapSwitch', function(event, state) {
        setIsVirtualButtonOn(state);
        setBackground();
    });

    var GROVE_BUTTON_UPDATE_MS = 100;
    function getIsGroveButtonOn() {
        erpc("getIsGroveButtonOn", null, function(result) {
            console.log('getIsGroveButtonOn', result);
                isGroveButtonOn = result;
                setTimeout(getIsGroveButtonOn, GROVE_BUTTON_UPDATE_MS);
                setBackground();
            },
            function(text) {
                console.log("error: " + text);
                setTimeout(getIsGroveButtonOn, GROVE_BUTTON_UPDATE_MS);
            });
    }
    getIsGroveButtonOn();

    demoInit('button');
});