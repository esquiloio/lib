/////////////////////////////////////////////////////////////////////////////
// Maxim DS18B20 1-Wire temperature sensor class
//
// 1-Wire Family: 0x28
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Example usage:
//
// /* Create a _onewire instance on UART1 */
// onewire <- Onewire(1);
//
// /* Search for the DS18B20 on the bus */
// rom <- onewire.searchRomFamily(0x28);
// if (!rom)
//    throw("DS18B20 not found");
//
// /* Create the DS18B20 instance */
// ds18b20 <- DS18B20(onewire, rom);
//
// /* Read the current temperature (/
// temp <- ds18b20.readT();
// print("temp = " + temp + "\n");
//
class DS18B20
{
    _onewire = null;
    _rom = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: onewire - _onewire bus instance to communicate over
//              rom - Blob with the 9 byte ROM code to address or null
//              to skip address
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS18B20::constructor(onewire, rom)
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
function DS18B20::address()
{
    if (_rom)
	    _onewire.matchRom(_rom);
    else
    	_onewire.skipRom();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    convertT
// Description: Start a temperature conversion
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS18B20::convertT()
{
    address();
    _onewire.writeCommand(0x44, null);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    isDone
// Description: Check if a delayed operation is done
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS18B20::isDone()
{
    _onewire.readbit();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readT
// Description: Start a temperature conversion and wait for the result
// Arguments:	None
// Return:		The temperature reading in degrees Celsius
/////////////////////////////////////////////////////////////////////////////
function DS18B20::readT()
{
    local data = blob(2);
    
    convertT();
    
    while (!_onewire.readbit())
        delay(50);

    readScratch(data);

    return data.readn('s') / 16.0;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readScratch
// Description: Read the scratch memory
// Arguments:	scratch - a blob from 1-9 bytes to hold the scratch data
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS18B20::readScratch(scratch)
{
    if (scratch.len() < 1 || scratch.len() > 9)
        throw("invalid blob");
    
    address();
    _onewire.readCommand(0xbe, scratch);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    writeScratch
// Description: Write the Th, Tl, and config parameters in the scratch
//              memory
// Arguments:	th - The high temperature alarm threshold in degrees Celsius
//              tl - The low temperature alarm threshold in degrees Celsius
//              config - The device configuration byte (see datasheet)
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS18B20::writeScratch(th, tl, config)
{
    local data = blob(3);
    
    data[0] = th;
    data[1] = tl;
    data[2] = config;
    
    address();
    _onewire.writeCommand(0x4e, data);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    copyScratch
// Description: Copies the Th, Tl, and config parameters from the scratch
//              memory to EEPROM
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS18B20::copyScratch()
{
    address();
    _onewire.writeCommand(0x48, null);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    recallE2
// Description: Read the Th, Tl, and config parameters from EEPROM and write
//              them to the scratch memory
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS18B20::recallE2()
{
    address();
    _onewire.writeCommand(0xb8, data);
    
    while (!_onewire.readbit())
        delay(50);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readPower
// Description: Determines if the device is powered or running parasitically
// Arguments:	None
// Return:		true if powered or falseif running parasitically
/////////////////////////////////////////////////////////////////////////////
function DS18B20::readPower()
{
    address();
    _onewire.writeCommand(0xb4, null);
	return _onewire.readbit();
}
