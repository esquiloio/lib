// Grove RGB LCD Demo
//
// Ported from:
//   https://github.com/Seeed-Studio/Sketchbook_Starter_Kit_V2.0
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

// Uses a Grove Button to control a Grove LED.
//  - Connect the Grove RGB LCD to an I2C socket
//  - Set Grove Base Shield VCC switch to 5V

// Import the RGB and LCD drivers for the chips the Grove board uses
dofile("sd:/lib/displays/PCA9633/PCA9633.nut");
dofile("sd:/lib/displays/JHD1214/JHD1214.nut");

i2c <- I2C(0);

led <- PCA9633(i2c, 0x62);
led.on()
led.setColor(0x039deb);

lcd <- JHD1214(i2c, 0x3E);
lcd.write("Hello IoT!");

// ERPC method to set display state from the web app
function displayPower(value)
{
    if (value) {
        led.on();
        lcd.on();
    } else {
        led.off();
        lcd.off();
    }
}

// ERPC method to set backlight colors
function setLedColors(params)
{
    led.setColors(params.red, params.green, params.blue);
}

// ERPC method to set display text from the web app
function displayText(value)
{
    lcd.clear();
    lcd.write(value);
}