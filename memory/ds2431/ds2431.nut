/////////////////////////////////////////////////////////////////////////////
// Maxim DS2431 1K-bit 1-Wire EEPROM class
//
// 1-Wire Family: 0x2d
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Example usage:
//
// /* Create a Onewire instance on UART1 */
// onewire <- Onewire(1);
//
// /* Search for the DS2431 on the bus */
// rom <- onewire.searchRomFamily(0x2d);
// if (!rom)
//    throw("DS2431 not found");
//
// /* Create the DS2431 instance */
// ds2431 <- DS2431(onewire, rom);
//
// /* Create a read buffer */
// buffer <- blob(16);
//
// /* Read from the EEPROM at address 0x100 */
// ds2431.read(0x100, buffer);
//
class DS2431
{
    _onewire = null;
    _rom = null;
    _size = 0x80;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: _onewire - Onewire bus instance to communicate over
//              _ rom - Blob with the 9 byte ROM code to address or null
//              to skip address
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS2431::constructor(onewire, rom)
{
    _onewire = onewire;
    _rom = rom;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    address
// Description: Address the device for a subsequent read or write command
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS2431::address()
{
    if (_rom)
	    _onewire.matchRom(_rom);
    else
    	_onewire.skipRom();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    write
// Description: Write to the EEPROM
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS2431::write(addr, data)
{
    local scratch = blob(11);
    
	writeScratch(addr, data);
    
    readScratch(scratch);
    
    for (local i = 0; i < 8; i++)
        if (data[i] != scratch[i + 3])
        	throw("verify error");
        
    copyScratch(scratch.readblob(3));
    
    delay(15);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    read
// Description: Read from the EEPROM memory
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS2431::read(addr, data)
{
    local addrblob = blob();
    
    if (addr < 0 || addr + data.len() > _size)
        throw("invalid address");
    
    addrblob.writen(addr, 'w');
    
    address();
    _onewire.writeCommand(0xf0, addrblob);
    _onewire.read(data);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readScratch
// Description: Read the scratch memory
// Arguments:	None
// Return:		A 9-byte blob containing the scratch memory or null on
//              failure
/////////////////////////////////////////////////////////////////////////////
function DS2431::readScratch(scratch)
{
    if (scratch.len() < 1 || scratch.len() > 11)
        throw("invalid blob");
    
    address();
    _onewire.readCommand(0xaa, scratch);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    writeScratch
// Description: Write the scratchpad
// Arguments:	addr - Memory address
//              data - Data to write as a blob
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS2431::writeScratch(addr, data)
{
    local scratch = blob();
    
    if (addr % 8 != 0 || addr < 0 || addr >= _size)
        throw("invalid address");
        
    if (data.len() != 8)
        throw("invalid data length");
    
    scratch.writen(addr, 'w');
    scratch.writeblob(data);
    
    address();
    _onewire.writeCommand(0x0f, scratch);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    copyScratch
// Description: Copies the scratchpad contents to the EEPROM
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS2431::copyScratch(auth)
{
    if (auth.len() != 3)
        throw("invalid authorization");
    
    address();
    _onewire.writeCommand(0x55, auth);
}

