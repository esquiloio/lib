/////////////////////////////////////////////////////////////////////////////
// Worldsemi WS2812 intelligent RGB LED class
// (aka Adafruit NeoPixels)
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Note: WS2812 changes do not take effect until update() is called
//
// Example usage:
//
// /* Create a chain of 4 NeoPixels on UART1 */
// neopixels <- WS2812(1, 4);
//
// /* Put on a random light show */
// while (true) {
//   neopixels.setColor(rand() % 10, rand() % 0x1000000);
//   neopixels.update();
//   delay(50);
// }
//

class WS2812
{
    _flexwire = null;
    _devices = 0;
    _buffer = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a WS2812 instance
// Arguments:	uartbus - the UART bus number connected to the WS2812 chain
//              devices - the number of WS2812 devices in the chain
/////////////////////////////////////////////////////////////////////////////
function WS2812::constructor(uartbus, devices)
{
    if (devices <= 0)
        throw("invalid number of devices");
    
    // Flexwire parameters
    // Bit rate: 250kbps (4us period)
    // Output zero: 400ns (1 slot)
    // Output one: 800ns (2 slots)
    // Input: N/A
    // Active: high (invert)
    // Endian: big
    _flexwire = Flexwire(uartbus, 1, 2, 1, 1);
	_flexwire.invert(true);
    _flexwire.lendian(false);
	_flexwire.speed(250000);
    
    _devices = devices;
    
    _buffer = blob(devices * 3);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    update
// Description: Update the devices on the chain with the display buffer
// Arguments:	None
/////////////////////////////////////////////////////////////////////////////
function WS2812::update()
{
    // Bump to the highest priority to keep from getting interrupted
    // since that would be interpreted by the devices as a reset
    local last = priority(0);
	_flexwire.write(_buffer);
    priority(last);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    off
// Description: Turn off all devices in the chain and update
// Arguments:	None
/////////////////////////////////////////////////////////////////////////////
function WS2812::off()
{
    for (local index = 0; index < _devices; index++)
    	setColor(index, 0);
    update();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    save
// Description: Return the current display buffer
// Return:	    A copy of the display buffer as a blob
/////////////////////////////////////////////////////////////////////////////
function WS2812::save()
{
    return (clone _buffer);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    restore
// Description: Restore a previously save display buffer
// Arguments:	buffer - The display buffer as a blob
/////////////////////////////////////////////////////////////////////////////
function WS2812::restore(buffer)
{
    if (buffer.size() != _buffer.size())
        throw("invalid buffer");
    
    _buffer = clone buffer;
    np.update();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setColor
// Description: Set the WS2812 color from a hexadecimal RGB value
// Arguments:	index - The device index on the chain
//              value - RGB value from 0x000000 to 0xffffff
/////////////////////////////////////////////////////////////////////////////
function WS2812::setColor(index, value)
{
    setRed(index, (value >> 16) & 0xff);
    setGreen(index, (value >> 8) & 0xff);
    setBlue(index, (value >> 0) & 0xff);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getColor
// Description: Get the WS2812 color as a hexadecimal RGB value
// Arguments:	index - The device index on the chain
/////////////////////////////////////////////////////////////////////////////
function WS2812::getColor(index)
{
    local value = 0;

    value = value | getRed() << 16;
    value = value | getGreen() << 8;
    value = value | getBlue();

    return value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setColors
// Description: Set the WS2812 color from the component values passed in
// Arguments:	index - The device index on the chain
//              red   - WS2812 red color component (0 - 255)
//              green - WS2812 green color component (0 - 255)
//              blue  - WS2812 blue color component (0 - 255)
/////////////////////////////////////////////////////////////////////////////
function WS2812::setColors(index, red, green, blue)
{
    setRed(index, red);
    setGreen(index, green);
    setBlue(index, blue);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getColors
// Description: Get the WS2812 color components
// Arguments:	index - The device index on the chain
// Return:      Table with RGB component values
//              e.g. { red: 10, green: 50, blue: 0 }
/////////////////////////////////////////////////////////////////////////////
function WS2812::getColors(index)
{
    return {
        red   = getRed(index),
        green = getGreen(index),
        blue  = getBlue(index)
        }
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setRed
// Description: Set the WS2812 red color component
// Arguments:	index - The device index on the chain
//              value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function WS2812::setRed(index, value)
{
    _buffer[index * 3 + 1] = value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getRed
// Description: Get the WS2812 red color component
// Arguments:	index - The device index on the chain
// Return:      value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function WS2812::getRed(index)
{
    return _buffer[index * 3 + 1];
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setGreen
// Description: Set the WS2812 green color component
// Arguments:	index - The device index on the chain
//              value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function WS2812::setGreen(index, value)
{
    _buffer[index * 3] = value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getGreen
// Description: Get the WS2812 green color component
// Arguments:	index - The device index on the chain
// Return:      value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function WS2812::getGreen(index)
{
    return _buffer[index * 3];
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setBlue
// Description: Set the WS2812 blue color component
// Arguments:	index - The device index on the chain
//              value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function WS2812::setBlue(index, value)
{
    _buffer[index * 3 + 2] = value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getBlue
// Description: Get the WS2812 blue color component
// Arguments:	index - The device index on the chain
// Return:      value - 0 to 255
/////////////////////////////////////////////////////////////////////////////
function WS2812::getBlue(index)
{
    return _buffer[index * 3 + 2];
}
