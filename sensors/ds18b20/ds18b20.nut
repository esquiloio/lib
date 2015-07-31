/////////////////////////////////////////////////////////////////////////////
// DS18B20 class
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
// /* Search for the DS18B20 on the bus */
// rom <- onewire.searchRomFamily(DS18B20_ROM_FAMILY);
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
    onewire = null;
    rom = null;
}

const DS18B20_ROM_FAMILY = 0x28;

function DS18B20::constructor(_onewire, _rom)
{
    onewire = _onewire;
    rom = _rom;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    address
// Description: Address the device for a subsequent read or write command
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS18B20::address()
{
    if (rom)
	    onewire.matchRom(rom);
    else
    	onewire.skipRom();
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
    onewire.writeCommand(0x44, null);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    isDone
// Description: Check if a delayed operation is done
// Arguments:	None
// Return:		None
/////////////////////////////////////////////////////////////////////////////
function DS18B20::isDone()
{
    onewire.readbit();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readT
// Description: Start a temperature conversion and wait for the result
// Arguments:	None
// Return:		The temperature reading in degrees Celsius
/////////////////////////////////////////////////////////////////////////////
function DS18B20::readT()
{
    convertT();
    
    while (!onewire.readbit())
        delay(50);

    local data = readScratch();

    return data.readn('s') / 16.0;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readScratch
// Description: Read the scratch memory
// Arguments:	None
// Return:		A 9-byte blob containing the scratch memory or null on
//              failure
/////////////////////////////////////////////////////////////////////////////
function DS18B20::readScratch()
{
    address();
    return onewire.readCommand(0xbe, 9);
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
    onewire.writeCommand(0x4e, data);
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
    onewire.writeCommand(0x48, null);
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
    onewire.writeCommand(0xb8, data);
    
    while (!onewire.readbit())
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
    onewire.writeCommand(0xb4, null);
	return onewire.readbit();
}
