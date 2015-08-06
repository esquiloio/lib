/////////////////////////////////////////////////////////////////////////////
// Titan Micro Electronics TM1637 LED driver class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////

const TM1367_DATA_WRITE       = 0x40;
const TM1367_DATA_READ        = 0x42;
const TM1367_DATA_WRITE_FIXED = 0x44;
const TM1367_ADDR_WRITE       = 0xc0;
const TM1367_DISPLAY_CONTROL  = 0x80;

class TM1637
{
    _clk = null;
    _data = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a TM1367 class instance
// Arguments:   clk - GPIO instance for clock signal
//              data - GPIO instance for _data signal
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
    
    commandWrite(TM1367_ADDR_WRITE | grid, segments);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readKey
// Description: Read the key that is currently pressed
// Arguments:   None
// Return:      -1 for no key or a key code of the form S0 S1 S2 K1 K2
/////////////////////////////////////////////////////////////////////////////
function TM1637::readKey()
{
    local code = commandRead(TM1367_DATA_READ);
    
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
    
	command(TM1367_DISPLAY_CONTROL | 0x8 | brightness);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    off
// Description: Turn the LED display off
// Arguments:   None
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::off()
{
	command(TM1367_DISPLAY_CONTROL);
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
// Description: Write a command and a _data value to the device
// Arguments:   id - the command byte
//              value - the _data byte
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
// Description: Write a command and read a _data value from the device
// Arguments:   id - the command byte
// Return:      the _data byte read
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
    
    _data.high();
    _clk.low();
    _clk.high();
    
  	if (_data.read())
        throw("write nack");
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
        _clk.high();
        if (_data.ishigh())
        	value = value | (1 << i);
    }
    
    _data.low();
    _clk.low();
    _clk.high();
    
    return value;
}
