/////////////////////////////////////////////////////////////////////////////
// Hunter Irrigation Bus Class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
require("Flexwire");

class Hunter
{
    _flexwire = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a Hunter instance
// Arguments:	uartbus - the UART bus number connected to the REM port
//                        of the Hunter irrigation controller
/////////////////////////////////////////////////////////////////////////////
function Hunter::constructor(uartbus)
{
    // Flexwire parameters
    // Bit rate: 480bps (2.083ms period)
    // Output zero: 0.208ms (1 slot)
    // Output one: 1.875ms (8 slots)
    // Input: N/A
    // Active: high (invert)
    // Open drain: false
    // Endian: big
    _flexwire = Flexwire(uartbus, 1, 9, 1, 1);
	_flexwire.invert(true);
    _flexwire.lendian(false);
    _flexwire.opendrain(false);
	_flexwire.speed(480);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    stop
// Description: Stop all zones
// Arguments:	None
/////////////////////////////////////////////////////////////////////////////
function Hunter::stop()
{
    start(1, 0);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    start
// Description: Start a zone
// Arguments:	zone - zone number (1-48)
//              time - time in minutes (0-240)
/////////////////////////////////////////////////////////////////////////////
function Hunter::start(zone, time)
{
    local buffer = blob(15);
    
    if (zone < 1 || zone > 48)
        throw("invalid zone");
    
    if (time < 0 || time > 240)
        throw("invalid time");
    
    // Start out with a base frame 
    buffer.writestr("\xff\x00\x00\x00\x10\x00\x00\x04\x00\x00\x01\x00\x01\xb8\x3f");
    
    // The bus protocol is a little bizzare, not sure why
    
    // Bits 9:10 are 0x1 for zones > 12 and 0x2 otherwise
    if (zone > 12)
        _bitfield(buffer, 9, 0x1, 2);
    else
        _bitfield(buffer, 9, 0x2, 2);
    
    // Zone + 0x17 is at bits 23:29 and 36:42
    _bitfield(buffer, 23, zone + 0x17, 7);
    _bitfield(buffer, 36, zone + 0x17, 7);
    
    // Zone + 0x23 is at bits 49:55 and 62:68
    _bitfield(buffer, 49, zone + 0x23, 7);
    _bitfield(buffer, 62, zone + 0x23, 7);
    
    // Zone + 0x2f is at bits 75:81 and 88:94
    _bitfield(buffer, 75, zone + 0x2f, 7);
    _bitfield(buffer, 88, zone + 0x2f, 7);

    // Time is encoded in three places and broken up by nibble
    // Low nibble:  bits 31:34, 57:60, and 83:86
    // High nibble: bits 44:47, 70:73, and 96:99
    _bitfield(buffer, 31, time, 4);
    _bitfield(buffer, 44, time >> 4, 4);
    _bitfield(buffer, 57, time, 4);
    _bitfield(buffer, 70, time >> 4, 4);
    _bitfield(buffer, 83, time, 4);
    _bitfield(buffer, 96, time >> 4, 4);

    // Bottom nibble of zone - 1 is at bits 109:112
    _bitfield(buffer, 109, zone - 1, 4);

    // Write the bits out of the bus
    _write(buffer, true);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    program
// Description: Run a program
// Arguments:	num - program number (1-4)
/////////////////////////////////////////////////////////////////////////////
function Hunter::program(num)
{
    local buffer = blob(7);
    
    if (num < 1 || num > 4)
        throw("invalid program");
    
    // Start with a basic program frame
    buffer.writestr("\xff\x40\x03\x96\x09\xbd\x7f");
    
    // Program number - 1 is at bits 31:32
    _bitfield(buffer, 31, num - 1, 2);
    
    _write(buffer, false);
}

/////////////////////////////////////////////////////////////////////////////
// Private Methods
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// Function:    _write
// Description: Write the bit sequence out of the bus
// Arguments:	buffer - blob containing the bits to transmit
//              extrabit - if true, then write an extra 1 bit
/////////////////////////////////////////////////////////////////////////////
function Hunter::_write(buffer, extrabit)
{
    // Bus start sequence
    _flexwire.invert(false);
    delay(325);
    _flexwire.invert(true);
    delay(65);
    
    // Write the start pulse
    _flexwire.invert(false);
    udelay(900);
    _flexwire.invert(true);
    
    // Write the bits out
    _flexwire.write(buffer);
    
    // Include an extra 1 bit
    if (extrabit)
    	_flexwire.writebit(true);
    
    // Write the stop pulse
    _flexwire.writebit(false);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    _bitfield
// Description: Set a value with an arbitrary bit width to a bit position
//              within a blob
// Arguments:	bits - blob to write the value to
//              pos - bit position within the blob
//              val - value to write
//              len - len in bits of the value
/////////////////////////////////////////////////////////////////////////////
function Hunter::_bitfield(bits, pos, val, len)
{
    while (len > 0) {
        if (val & 0x1)
            bits[pos / 8] = bits[pos / 8] | 0x80 >> (pos % 8);
        else
            bits[pos / 8] = bits[pos / 8] & ~(0x80 >> (pos % 8));
        len--;
        val = val >> 1;
        pos++;
    }
}
