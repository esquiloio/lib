// RGB LED Demo using an AdaFruit NeoPixel
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
require("math");

// Import the WS2812 class
dofile("sd:/lib/displays/ws2812/ws2812.nut");

// NeoPixel is on UART1
led <- WS2812(1, 1);

// Initialize to Esquilo blue
led.setColor(0, 0x039deb);
led.update();

// Disco mode state
isDiscoOn <- false;

// ERPC method to set colors
function setLedColors(params)
{
    led.setColors(0, params.red, params.green, params.blue);
    led.update();
}

// ERPC method to fetch colors
function getLedColors()
{
    return led.getColors(0);
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
    if (isDiscoOn) {
        led.setColors(0, randomColor(), randomColor(), randomColor());
        led.update();
    }
    delay(DISCO_DELAY_MS);
}
