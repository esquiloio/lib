// RGB LED Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
require(["PWM", "math"]);

// Import the RGB LED class
dofile("sd:/lib/displays/rgbled/rgbled.nut");

// RGB LED is on pins 2, 3, and 4 (PWM0 channels 0, 1, and 2)
led <- RGBLED(PWM(0), 0, 1, 2);

// Initialize to Esquilo blue
led.setColor(0x039deb);
led.on();

// Disco mode state
isDiscoOn <- false;

// ERPC method to set colors
function setLedColors(params)
{
    led.setColors(params.red, params.green, params.blue);
}

// ERPC method to fetch colors
function getLedColors()
{
    return led.getColors();
}

// ERPC method to set disco mode
function setIsDiscoOn(value)
{
    isDiscoOn = value;
}

// Returns a random color in range 0 to 255
function randomColor()
{
    return floor((rand().tofloat() / RAND_MAX) * 255);
}

// Background loop
const DISCO_DELAY_MS = 150;
while (true) {
    if (isDiscoOn)
        led.setColors(randomColor(), randomColor(), randomColor());
    delay(DISCO_DELAY_MS);
}
