/////////////////////////////////////////////////////////////////////////////
// Titan Micro Electronics TM1637 LED driver class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////

const TM1367_DATA_WRITE = 0x40;
const TM1367_DATA_READ = 0x42;
const TM1367_DATA_WRITE_FIXED = 0x44;
const TM1367_ADDR_WRITE = 0xc0;
const TM1367_DISPLAY_CONTROL = 0x80;

class TM1637
{
    clk = null;
    data = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a TM1367 class instance
// Arguments:   None
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::constructor(_clk, _data)
{
	clk = _clk;
    data = _data;
    
    clk.output();
    data.opendrain(true);
    data.output();
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
    clk.high();
    data.high();
    data.low();
    clk.low();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    stop
// Description: Issue a bus stop sequence
// Arguments:   None
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function TM1637::stop()
{
    clk.low();
    data.low();
    clk.high();
    data.high();
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
        clk.low();
        if (value & 0x01)
            data.high();
        else
            data.low();
        value = (value >> 1);
        clk.high();
    }
    
    data.high();
    clk.low();
    clk.high();
    
  	if (data.read())
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
    
    data.high();
    
    for(local i = 0; i < 8; i++) {
        clk.low();
        clk.high();
        if (data.ishigh())
        	value = value | (1 << i);
    }
    
    data.low();
    clk.low();
    clk.high();
    
    return value;
}
