// Grove Light Sensor Demo
//
// Ported from:
//   https://github.com/Seeed-Studio/Sketchbook_Starter_Kit_V2.0
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

// Turns a Grove LED on when a Grove Sound Sensor detects sound over a defined
// threshold
//
// Connect the Grove Light Sensor module to the socket marked A0
// Connect the Grove LED Socket module to the socket marked D3

require(["ADC", "GPIO", "math"]);

// Defines the ADC (analog-to-digital converter) to which the light sensor is connected
const ADC_LIGHT         = 0;
const ADC_LIGHT_CHANNEL = 0;

light <- ADC(ADC_LIGHT);

// LED control
const PIN_LED    = 3;

// Configure the LED's pin for output
led <- GPIO(PIN_LED);
led.output();

brightness <- 50;

const LIGHT_DETECT_THRESHOLD = 20;

// ERPC to fetch current brightness
function getBrightness()
{
    return brightness;
}

while(true) {
    // Read the value of the sensor
    local value = light.readv(ADC_LIGHT_CHANNEL);
    // Calculate the light level as a percentage of the full range
    local percent = ceil(value * 100.0 / 3.3);

    // If the measured lgiht level is below the threshold, turn on the LED
    if (percent <= LIGHT_DETECT_THRESHOLD) {
        // Turn the LED on for 50ms, then turn it back off.
        led.high();
        brightness = 100;
        delay(250);
    } else {
        brightness = 50;
        led.low();
    }

    delay(10);
}