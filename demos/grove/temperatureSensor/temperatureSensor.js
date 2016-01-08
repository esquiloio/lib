// Grove Temperature Sensor Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
$(document).ready(function() {
    var UPDATE_MS = 20;
    function getTemperature() {
        erpc("getTemperature", null, function(result) {
                var temperature = result;
                console.log('temperature', temperature);
                $('#temperature').text(Math.round(temperature*10)/10);
                setTimeout(getTemperature, UPDATE_MS);
            },
            function(text) {
                console.log("error: " + text);
                setTimeout(getTemperature, UPDATE_MS);
            });
    }
    getTemperature();

    demoInit('temperatureSensor');
});