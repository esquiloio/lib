/////////////////////////////////////////////////////////////////////////////
// Titan Micro Electronics TM1637 LED driver class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
// Example usage:
//
// /* Grove 4-Digit Display on D6 */
// display <- TM1637(GPIO(6), GPIO(7));
//
// /* 7-segment values for 0-9a-f */
// segs <- "\x3f\x06\x5b\x4f\x66\x6d\x7d\x07\x7f\x6f\x77\x7c\x39\x5e\x79\x71";
//
// /* Show ba55 on the display */
// display.writeSegments(0, segs[0xb]);
// display.writeSegments(1, segs[0xa]);
// display.writeSegments(2, segs[0x5]);
// display.writeSegments(3, segs[0x5]);
//
// /* Turn display on */
// display.on(4);

const TM1637_DATA_READ        = 0x42;
const TM1637_DATA_WRITE       = 0x44;
const TM1637_ADDR_WRITE       = 0xc0;
const TM1637_DISPLAY_OFF      = 0x80;
const TM1637_DISPLAY_ON       = 0x88;

class TM1637
{
    _clk = null;
    _data = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a TM1637 class instance
// Arguments:   clk - GPIO instance for clock signal
//              data - GPIO instance for data signal
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::constructor(clk, data)
{
	_clk = clk;
    _data = data;
    
    _clk.output();
    _data.opendrain(true);
    _data.output();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    writeSegments
// Description: Write the LED segments for a grid position
// Arguments:   grid - grid position (0-5)
//              segments - the eight segment values (0-255)
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::writeSegments(grid, segments)
{
    if (grid < 0 || grid > 5)
        throw("invalid grid");

    if (segments < 0 || segments > 255)
        throw("invalid segments");
    
    command(TM1637_DATA_WRITE);
    commandWrite(TM1637_ADDR_WRITE | grid, segments);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readKey
// Description: Read the key that is currently pressed
// Arguments:   None
// Return:      -1 for no key or a key code of the form S0 S1 S2 K1 K2
/////////////////////////////////////////////////////////////////////////////
function TM1637::readKey()
{
    local code = commandRead(TM1637_DATA_READ);
    
    if (code == 0xff)
        return -1;
    
    return (code >> 3);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    on
// Description: Turn the LED display on at the given brightness
// Arguments:   brightness - the brightness level (0-7)
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::on(brightness)
{
    if (brightness < 0 || brightness > 7)
        throw("invalid brightness");
    
	command(TM1637_DISPLAY_ON | brightness);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    off
// Description: Turn the LED display off
// Arguments:   None
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::off()
{
	command(TM1637_DISPLAY_OFF);
}

/////////////////////////////////////////////////////////////////////////////
// Private functions
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// Function:    command
// Description: Write a command to the device
// Arguments:   id - the command byte
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::command(id)
{
    start();
    writeByte(id);
    stop();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    commandWrite
// Description: Write a command and a data value to the device
// Arguments:   id - the command byte
//              value - the data byte
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::commandWrite(id, value)
{
    start();
    writeByte(id);
    writeByte(value);
    stop();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    commandRead
// Description: Write a command and read a data value from the device
// Arguments:   id - the command byte
// Return:      the data byte read
/////////////////////////////////////////////////////////////////////////////
function TM1637::commandRead(id)
{
    local value;
    
    start();
    writeByte(id);
    value = readByte();
    stop();

    return value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    start
// Description: Issue a bus start sequence
// Arguments:   None
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::start()
{
    _clk.high();
    _data.high();
    _data.low();
    _clk.low();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    stop
// Description: Issue a bus stop sequence
// Arguments:   None
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::stop()
{
    _clk.low();
    _data.low();
    _clk.high();
    _data.high();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    writeByte
// Description: Write a byte to the bus
// Arguments:   value - the byte value to write
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::writeByte(value)
{
    for(local i = 0; i < 8; i++) {
        _clk.low();
        if (value & 0x01)
            _data.high();
        else
            _data.low();
        value = (value >> 1);
        _clk.high();
    }
    
    _clk.low();
    _data.high();
    _clk.high();
    _data.input();
    
    bitDelay();
    local ack = _data.read();
    if (_data.islow()) {
        _data.output();
        _data.low();
    }
    bitDelay();
    _data.output();
    bitDelay();

    return ack;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readByte
// Description: Read a byte from the bus
// Arguments:   None
// Return:      the byte value read
/////////////////////////////////////////////////////////////////////////////
function TM1637::readByte()
{
    local value = 0;
    
    _data.high();
    
    for(local i = 0; i < 8; i++) {
        _clk.low();
        if (_data.ishigh())
        	value = value | (1 << i);
        _clk.high();
    }
    
    _clk.low();
    _data.low();
    _clk.high();
    
    return value;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    bitDelay
// Description: Delay for one bit time
// Arguments:   None
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::bitDelay()
{
	udelay(50);
}

