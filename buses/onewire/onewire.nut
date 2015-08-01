/////////////////////////////////////////////////////////////////////////////
// 1-Wire protocol class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Note: You MUST externally connect the UART Tx and Rx pins together
//
// Example usage:
//
// /* Create a Onewire instance on UART1 */
// onewire <- Onewire(1);
//
// /* Read the device memory */
// onewire.reset();
// onewire.skipRom();
// data <- onewire.commandRead(0xbe, 9)
//
class Onewire extends Flexwire
{
    last_discrepancy = 0;
    last_device = true;
    family_type = -1;
    search_rom = blob(8);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a Onewire instance on a UART bus
// Arguments:	uartbus - UART bus number to 
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function Onewire::constructor(uartbus)
{
    // Flexwire parameters
    // Bit rate: 15.4kbps (64.9us period)
    // Output zero: 58.4us (9 slots)
    // Output one: 6.49us (1 slot)
    // Input drive: 6.49us (1 slot)
    // Input start: slot 1
    // Active: low (no invert)
    // Endian: little
    base.constructor(uartbus, 9, 1, 1, 1);
    opendrain(true);
	lendian(true);
    invert(false);
	speed(15400);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    reset
// Description: Perform 1-Wire reset sequence and detects device presence
//              signal
// Arguments:	None
// Return:		true if device presence detected and false if not
/////////////////////////////////////////////////////////////////////////////
function Onewire::reset()
{
    return base.reset(480, 480);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    calcCrc8
// Description: Calculates the 1-Wire CRC-8 with polynomial x^8 + x^5 +
//              x^4 + 1 for a data blob
// Arguments:	data - blob containing the data
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function Onewire::calcCrc8(data)
{
    local crc = 0;
    local byte;
    
	for (local j = 0; j < data.size(); j++) {
        byte = data[j] << 1;
		for (local i = 0; i < 8; i++) {
            byte = byte >> 1;
            crc = crc >> 1;
            if ((byte ^ crc) & 0x1)
				crc = crc ^ 0x118;
		}
	}
    
	return (crc >> 1);
}

/////////////////////////////////////////////////////////////////////////////
// ROM command methods
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// Function:    readRom
// Description: Reads the device ROM code.  This only works if there is one
//              slave device on the bus.
// Arguments:	None
// Return:      Blob with the ROM code
/////////////////////////////////////////////////////////////////////////////
function Onewire::readRom()
{
    local rom = blob(8);
    
    if (!reset())
        return null;
    
    writebyte(0x33);
    
    read(rom);
    
    return rom;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    matchRom
// Description: Address a particular slave device with its ROM code.
// Arguments:	rom - blob with the ROM code to match
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function Onewire::matchRom(rom)
{
    reset();
    
    writebyte(0x55);
    write(rom);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    skipRom
// Description: Address a slave device without its ROM code.  This only works
//              if there is one slave device on the bus.
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function Onewire::skipRom()
{
    reset();
    
    write(0xcc);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    searchRomFirst
// Description: Start a slave device search.  Subsequent device are found
//              with searchRomNext.
// Arguments:	None
// Return:		ROM code for first slave device found on the bus or null
//              if none was found
/////////////////////////////////////////////////////////////////////////////
function Onewire::searchRomFirst()
{
    last_discrepancy = -1;
    last_device = false;
    family_type = -1;
    
    return searchRomNext();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    searchRomFamily
// Description: Start a slave device search limited to a device family type.
//              Subsequent device are found with searchRomNext.
// Arguments:	_family_type - device family type to search (0-255)
// Return:		ROM code for first slave device found on the bus or null
//              if none was found
/////////////////////////////////////////////////////////////////////////////
function Onewire::searchRomFamily(_family_type)
{
    search_rom[0] = _family_type;
    for (local i = 1; i < 8; i++)
        search_rom[i] = 0;
    
    last_discrepancy = 64;
    last_device = false;
    family_type = _family_type;
    
    return searchRomNext();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    searchRomNext
// Description: Find the next slave device on the bus after a searchRomFirst
//              or searchRomFamily call
// Arguments:	None
// Return:		ROM code for next slave device found on the bus or null if
//              none was found
/////////////////////////////////////////////////////////////////////////////
function Onewire::searchRomNext()
{
    local bit_number;
    local last_zero = 0;
    local byte_number;
    local bit;
    local cmp_bit;
    local byte_mask;
    local search_bit;

    if (last_device)
    	return null;

    if (!reset())
        return null;

    writebyte(0xF0);  
    
    for (bit_number = 0; bit_number < 64; bit_number++) {

        byte_mask = 1 << (bit_number % 8);
        byte_number = bit_number / 8;

        // Read the next ROM bit and its complement
        bit = readbit();
        cmp_bit = readbit();
        
        // Exit if no devices participating
        if (bit && cmp_bit)
            break;
    
        // All devices have the same bit value
        if (bit != cmp_bit) {
            search_bit = bit;
        }
        // There is a bit discrepency
        else {
            // If the discrepency is prior to the last one, then
            // use the bit from the saved ROM.
            if (bit_number < last_discrepancy)
                search_bit = ((search_rom[byte_number] & byte_mask) != 0);
            // Else the bit is 1 if we are at the same bit position as the
            // last discrepency else the bit is 0
            else
                search_bit = (bit_number == last_discrepancy);

            // Save the last zero bit position
            if (!search_bit)
                last_zero = bit_number;
        }
        
        // Set the bit in the saved ROM 
        if (search_bit)
            search_rom[byte_number] = search_rom[byte_number] | byte_mask;
        else
            search_rom[byte_number] = search_rom[byte_number] & ~byte_mask;
        
        // Write our chosen bit onto the bus
        writebit(search_bit);
    }
    
    // Check if the match is valid
    if (bit_number != 64 || calcCrc8(search_rom) != 0)
        return null;

    last_discrepancy = last_zero;

    if (last_discrepancy == 0)
        last_device = true;
    
    // Check the family if doing a family search
    if (family_type >= 0 && search_rom[0] != family_type)
        return null;
    
   	return (clone search_rom);
}
    
/////////////////////////////////////////////////////////////////////////////
// Function command methods
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// Function:    readCommand
// Description: Execute a 1-Wire read command after the device is addressed
// Arguments:	commandId - command ID byte (0-255)
//              length - number of bytes to read
// Return:		Blob containing the bytes read
/////////////////////////////////////////////////////////////////////////////
function Onewire::readCommand(commandId, length)
{
    local data;
    
    writebyte(commandId);
    data = blob(length);
    read(data);
    
    return data;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    writeCommand
// Description: Execute a 1-Wire write command after the device is addressed
// Arguments:	commandId - command ID byte (0-255)
//              data - blob containing the data to write
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function Onewire::writeCommand(commandId, data)
{
    writebyte(commandId);
    if (data)
    	write(data);
}
