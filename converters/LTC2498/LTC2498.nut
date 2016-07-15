/////////////////////////////////////////////////////////////////////////////
// Linear Technologies LTC2498 24-bit 16-channel delta-sigma ADC
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Example usage:
//
// const VREF = 3.0;
//
// spi <- SPI(1);
// spi.speed(1000000);
// spi.select(0);
//  
// adc <- LTC2498(spi);
// print("temperature = " + adc.temperature(VREF) + "\n");
//
// adc.read(0);
// for (local chan = 0; chan < 16; chan++) {
//     local voltage = adc.readv((chan + 1) % 16, VREF);
//     print("channel " + chan + " = " + voltage + "\n");
// }

require("SPI");

// C1 control byte values
const LTC2498_C1_EN			= 0x20;
const LTC2498_C1_SGL		= 0x10;
const LTC2498_C1_ODD		= 0x10;

// C2 control byte values
const LTC2498_C2_EN2		= 0x80;
const LTC2498_C2_IM			= 0x40;
const LTC2498_C2_FA			= 0x20;
const LTC2498_C2_FB			= 0x10;
const LTC2498_C2_SPD		= 0x08;

// EOC polling
const LTC2498_EOC_DELAY		= 10; // milliseconds
const LTC2498_EOC_POLLS		= 20;

// Filter enumeration
enum LTC2498_FILTER {
    F50HZ,
    F60HZ,
    FBOTH
}

class LTC2498
{
    _spi	= null;
    
    // 50Hz/60Hz filter setting
    _filter	= LTC2498_FILTER.FBOTH;
    
    // High speed flag
    _hspeed	= false;
    
    // Differential input flag
    _diff	= false;
    
    // Invert differential flag
    _invert	= false;
    
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a LTC2498 instance
// Arguments:	spi - the SPI instance connected to the LTC2498
/////////////////////////////////////////////////////////////////////////////
function LTC2498::constructor(spi)
{
    _spi = spi;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    filter
// Description: Set the 50Hz/60Hz filter
// Arguments:	filter - the filter setting to use from LTC2498_FILTER enum:
//                  F50HZ - Use the 50Hz filter
//                  F60HZ - Use the 60Hz filter
//                  FBOTH - Use both the 50Hz and 60Hz filters
// Return:      none
/////////////////////////////////////////////////////////////////////////////
function LTC2498::filter(filter)
{
    if (filter == FILTER_50HZ ||
        filter == FILTER_60HZ ||
        filter == FILTER_BOTH)
    	_filter = filter;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    hspeed
// Description: Set the high speed (2X) flag where the device will sample
//              twice as fast at the expense of skipping the offset cal.
// Arguments:	hspeed - true for 2X mode and false for 1X mode
// Return:      none
/////////////////////////////////////////////////////////////////////////////
function LTC2498::hspeed(hspeed)
{
    _hspeed = hspeed;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    diff
// Description: Use differential sampling for the channels.
// Arguments:	diff - true: the device samples differential inputs using
//                           adjacent channels
//                     false: the device samples single-ended inputs
//                            referenced from the COM input
/////////////////////////////////////////////////////////////////////////////
function LTC2498::diff(diff)
{
    _diff = diff;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    invert
// Description: Invert the polarity of the differential channels.  This
//              setting does nothing for single-ended inputs.
// Arguments:	invert - true: the higher channel number is positive
//                       false: the lower channel number is positive
// Return:      none
/////////////////////////////////////////////////////////////////////////////
function LTC2498::invert(invert)
{
    _invert = invert;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    temperature
// Description: Read the internal temperature sensor.
// Arguments:	vref - the voltage value on the REF+ pin
// Return:      the temperature in Celsius or null if the conversion failed
/////////////////////////////////////////////////////////////////////////////
function LTC2498::temperature(vref)
{
	local value;
	local temp;
	local c1;
    local c2;
    
    // Configuration bytes
   	c1 = LTC2498_C1_EN;
	c2 = LTC2498_C2_EN2 | LTC2498_C2_IM;

    // Configure the filter
    if (_filter == LTC2498_FILTER.F50HZ)
       	c2 = c2 | LTC2498_C2_FB;
    else if (_filter == LTC2498_FILTER.F60HZ)
       	c2 = c2 | LTC2498_C2_FA;
    
     // Start the conversion
    value = _xfer(c1, c2);
    if (value == null)
		return null;
        
    // Read the temperature value
    value = _xfer(0, 0);
    if (value == null)
		return null;
    
    // Convert to temperature by multiply the reference voltage and dividing
    // by 32.0, the temperature slope of 93.5uV/K, and 2^24.  Then subtract
    // 273 to convert Kelvin to Celsius.
	temp = (value * vref) / 50197.430272 - 273.0;

	return temp;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    read
// Description: Read the ADC converter and return the binary value which
//              includes a 27-bit signed integer and a 5-bit fractional part.
//              Divide the result by 32 to discard the fractional part.
// Arguments:	channel - the channel number to sample.  In differential
//                        mode, specify either channel of the pair.
// Return:      the converter value or null if the conversion failed
/////////////////////////////////////////////////////////////////////////////
function LTC2498::read(channel)
{
	local c1;
	local c2;

    // Channel range check
    if (channel < 0 || channel >= 16)
        return null;

    // Configuration bytes
	c1 = LTC2498_C1_EN | (channel / 2);
	c2 = LTC2498_C2_EN2;

    // Differential mode
    if (_diff) {
        if (invert)
        	c1 = c1 | LTC2498_C1_ODD;
    }
    // Single-ended mode
    else {
        c1 = c1 | LTC2498_C1_SGL;
        if (channel & 0x1)
            c1 = c1 | LTC2498_C1_ODD;
    }

    // Configure the filter
    if (_filter == LTC2498_FILTER.F50HZ)
       	c2 = c2 | LTC2498_FB;
    else if (_filter == LTC2498_FILTER.F60HZ)
       	c2 = c2 | LTC2498_FA;
    
    // Return the input from the SPI transfer
    return _xfer(c1, c2);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readv
// Description: Read the ADC converter and return the voltage.
// Arguments:	channel - the channel number to sample.  In differential
//                        mode, specify either channel of the pair.
// Return:      the channel voltage
/////////////////////////////////////////////////////////////////////////////
function LTC2498::readv(channel, vref)
{
    local value;
    
    // Read the binary value
    value = read(channel);
    if (value == null)
        return null;
    
    // Convert the binary value to voltage by multiplying by the reference
    // voltage and dividing by both 32.0 and 2^24
    return (value * vref / 536870912.0);
}

/////////////////////////////////////////////////////////////////////////////
// Private Methods
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// Function:    _xfer
// Description: Perform the SPI transfer with the device.
// Arguments:	c1 - configuration byte 1
// 				c2 - configuration byte 2
// Return:      the 32-bit value returned from the device
/////////////////////////////////////////////////////////////////////////////
function LTC2498::_xfer(c1, c2)
{
    local txBuff = blob(4);
    local rxBuff = blob(4);
    local value;
    
    txBuff[0] = 0x80 | c1;
    txBuff[1] = c2;

    for (local i = 0; i < LTC2498_EOC_POLLS; i++) {    
    	_spi.xfer(txBuff, rxBuff);
        
        if ((rxBuff[0] & 0x80) == 0) {
            value = swap4(rxBuff.readn('i'));
            value -= 0x20000000;
            return value;
        }
        
	    delay(LTC2498_EOC_DELAY);
    }

	return null;
}

