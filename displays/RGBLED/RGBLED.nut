/////////////////////////////////////////////////////////////////////////////
// RGB LED
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Example usage:
//
// /* Pins 2, 3, and 4 (PWM0 channels 0, 1, and 2)*/
// led <- RGBLED(PWM(0), 0, 1, 2);
// led.on()
// led.setColor(0x039deb);
//

class RGBLED
{
    _pwm     = null;
    _chRed   = 0;
    _chGreen = 0;
    _chBlue  = 0;
    _red     = 0;
    _green   = 0;
    _blue    = 0;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    Class Constructor
// Description: Create
// Arguments:   pwm     - PWM object to drive the LED with
//              chRed   - PWM channel number for red
//              chGreen - PWM channel number for green
//              chBlue  - PWM channel number for blue
/////////////////////////////////////////////////////////////////////////////
function RGBLED::constructor(pwm, chRed, chGreen, chBlue)
{
    _pwm     = pwm;
    _chRed   = chRed;
    _chGreen = chGreen;
    _chBlue  = chBlue;
    setColors(0, 0, 0);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    on
// Description: Turn the RGB LED on
// Arguments:	None
/////////////////////////////////////////////////////////////////////////////
function RGBLED::on()
{
    _pwm.on(_chRed);
    _pwm.on(_chGreen);
    _pwm.on(_chBlue);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    off
// Description: Turn the RGB LED off
// Arguments:	None
/////////////////////////////////////////////////////////////////////////////
function RGBLED::off()
{
    _pwm.off(_chRed);
    _pwm.off(_chGreen);
    _pwm.off(_chBlue);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setColor
// Description: Set the RGB LED color from a hexadecimal RGB value
// Arguments:	value - RGB value from 0x000000 to 0xffffff
/////////////////////////////////////////////////////////////////////////////
function RGBLED::setColor(value)
{
    setRed((value >> 16) & 0xff);
    setGreen((value >> 8) & 0xff);
    setBlue((value >> 0) & 0xff);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getColor
// Description: Get the RGB LED color as a hexadecimal RGB value
// Arguments:	None
/////////////////////////////////////////////////////////////////////////////
function RGBLED::getColor()
{
    local value = 0;

    value = value | getRed() << 16;
    value = value | getGreen() << 8;
    value = value | getBlue();

    return value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setColors
// Description: Set the RGB LED color from the component values passed in
// Arguments:	red   - RGB LED red color component (0 - 255)
//              green - RGB LED green color component (0 - 255)
//              blue  - RGB LED blue color component (0 - 255)
/////////////////////////////////////////////////////////////////////////////
function RGBLED::setColors(red, green, blue)
{
    setRed(red);
    setGreen(green);
    setBlue(blue);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getColors
// Description: Get the RGB LED color components
// Arguments:	None
// Return:      Table with RGB component values
//              e.g. { red: 10, green: 50, blue: 0 }
/////////////////////////////////////////////////////////////////////////////
function RGBLED::getColors()
{
    return {
        red   = getRed(),
        green = getGreen(),
        blue  = getBlue()
        }
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setRed
// Description: Set the RGB LED red color component
// Arguments:	value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function RGBLED::setRed(value)
{
    _setChannel(_chRed, value);
    _red = value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getRed
// Description: Get the RGB LED red color component
// Arguments:	None
// Return:      value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function RGBLED::getRed()
{
    return _red;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setGreen
// Description: Set the RGB LED green color component
// Arguments:	value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function RGBLED::setGreen(value)
{
    _setChannel(_chGreen, value);
    _green = value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getGreen
// Description: Get the RGB LED green color component
// Arguments:	None
// Return:      value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function RGBLED::getGreen()
{
    return _green;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setBlue
// Description: Set the RGB LED blue color component
// Arguments:	value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function RGBLED::setBlue(value)
{
    _setChannel(_chBlue, value);
    _blue = value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getBlue
// Description: Get the RGB LED blue color component
// Arguments:	None
// Return:      value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function RGBLED::getBlue()
{
    return _blue;
}

/////////////////////////////////////////////////////////////////////////////
// Private functions
/////////////////////////////////////////////////////////////////////////////
function RGBLED::_setChannel(channel, value)
{
    if (value < 0 || value > 255)
        throw("invalid value");
    _pwm.duty_cycle(channel, 100 * value / 255);
}