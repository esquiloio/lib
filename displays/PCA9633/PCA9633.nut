/////////////////////////////////////////////////////////////////////////////
// NXP PCA9633 I2C RGB LED class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Example usage:
//
// local led = PCA9633(I2C(0), 0x62);
// led.on()
// led.setColor(0x039deb);
// delay(500);
// led.off();
// delay(500);
// led.on();
// local colors = led.getColors();
// print("rgb: " + colors.red + " " + colors.green + " " + colors.blue + " \n");
//
require("I2C");

const PCA9633_MODE1  = 0x00;
const PCA9633_MODE2  = 0x01;
const PCA9633_PWM0   = 0x02;
const PCA9633_PWM1   = 0x03;
const PCA9633_PWM2   = 0x04;
const PCA9633_LEDOUT = 0x08;
const PCA9633_LEDOUT_OFF = 0x00;
const PCA9633_LEDOUT_PWM = 0xAA;

class PCA9633
{
    _i2c     = null;
    _address = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a PCA9633 instance
// Arguments:	i2c - I2C bus the PCA9633 is connnected to
//              address - I2C address of the PCA9633
/////////////////////////////////////////////////////////////////////////////
function PCA9633::constructor(i2c, address)
{
    _i2c     = i2c;
    _address = address;

    _writeRegister(PCA9633_MODE1, 0);
    _writeRegister(PCA9633_MODE2, 0);
    off();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    off
// Description: Turn off the LED
// Arguments:	None
/////////////////////////////////////////////////////////////////////////////
function PCA9633::off()
{
    _writeRegister(PCA9633_LEDOUT, PCA9633_LEDOUT_OFF);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    on
// Description: Turn on the LED
// Arguments:	None
/////////////////////////////////////////////////////////////////////////////
function PCA9633::on()
{
    _writeRegister(PCA9633_LEDOUT, PCA9633_LEDOUT_PWM);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setColor
// Description: Set the PCA9633 color from a hexadecimal RGB value
// Arguments:	value - RGB value from 0x000000 to 0xffffff
/////////////////////////////////////////////////////////////////////////////
function PCA9633::setColor(value)
{
    setRed((value >> 16) & 0xff);
    setGreen((value >> 8) & 0xff);
    setBlue((value >> 0) & 0xff);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getColor
// Description: Get the PCA9633 color as a hexadecimal RGB value
// Arguments:	None
/////////////////////////////////////////////////////////////////////////////
function PCA9633::getColor()
{
    local value = 0;

    value = value | getRed() << 16;
    value = value | getGreen() << 8;
    value = value | getBlue();

    return value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setColors
// Description: Set the PCA9633 color from the component values passed in
// Arguments:   red   - PCA9633 red color component (0 - 255)
//              green - PCA9633 green color component (0 - 255)
//              blue  - PCA9633 blue color component (0 - 255)
/////////////////////////////////////////////////////////////////////////////
function PCA9633::setColors(red, green, blue)
{
    setRed(red);
    setGreen(green);
    setBlue(blue);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getColors
// Description: Get the PCA9633 color components
// Arguments:	None
// Return:      Table with RGB component values
//              e.g. { red: 10, green: 50, blue: 0 }
/////////////////////////////////////////////////////////////////////////////
function PCA9633::getColors()
{
    return {
        red   = getRed(),
        green = getGreen(),
        blue  = getBlue()
}
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setRed
// Description: Set the PCA9633 red color component
// Arguments:   value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function PCA9633::setRed(value)
{
    _writeRegister(PCA9633_PWM2, value);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setGreen
// Description: Set the PCA9633 red color component
// Arguments:   value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function PCA9633::setGreen(value)
{
    _writeRegister(PCA9633_PWM1, value);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setBlue
// Description: Set the PCA9633 red color component
// Arguments:   value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function PCA9633::setBlue(value)
{
    _writeRegister(PCA9633_PWM0, value);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getRed
// Description: Get the PCA9633 red color component
// Arguments:	None
// Return:      value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function PCA9633::getRed()
{
    return _readRegister(PCA9633_PWM2);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getGreen
// Description: Get the PCA9633 green color component
// Arguments:	None
// Return:      value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function PCA9633::getGreen()
{
    return _readRegister(PCA9633_PWM1);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getBlue
// Description: Get the PCA9633 blue color component
// Arguments:	None
// Return:      value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function PCA9633::getBlue()
{
    return _readRegister(PCA9633_PWM0);
}

/////////////////////////////////////////////////////////////////////////////
// Private Functions
/////////////////////////////////////////////////////////////////////////////

function PCA9633::_writeRegister(address, value)
{
    _i2c.address(_address);
    _i2c.write8(address, value);
}

function PCA9633::_readRegister(address)
{
    _i2c.address(_address);
    return _i2c.read8(address);
}