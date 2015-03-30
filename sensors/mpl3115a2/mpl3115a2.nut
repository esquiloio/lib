/////////////////////////////////////////////////////////////////////////////
// Freescale MPL3115A2 altimeter sensor class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
class MPL3115A2
{
    i2c = null;
    addr = 0;
}

const MPL3115A2_STATUS       = 0x00;
const MPL3115A2_OUT_P_MSB    = 0x01;
const MPL3115A2_OUT_T_MSB    = 0x04;
const MPL3115A2_WHOAMI       = 0x0c;
const MPL3115A2_PT_DATA_CFG  = 0x13;
const MPL3115A2_CTRL_REG1    = 0x26;

function MPL3115A2::constructor(_i2c, _addr)
{
    i2c = _i2c;
    addr = _addr;
    
    i2c.address(addr);

    // Make sure the MPL3115A2 is there
    if (i2c.read8(MPL3115A2_WHOAMI) != 0xc4)
        throw("MPL3115A2 device not found");
 
    // write 0010 0001 = 0x21 to control register 1
    // [7]: alt=0: barometer mode
    // [6]: raw=0: no raw data
    // [5-3]: os=100=4: 16 times oversample
    // [2]: rst=0: no reset
    // [1]: ost=0: no immediate measurement
    // [0]: sbyb=1 part active
    i2c.write8(MPL3115A2_CTRL_REG1, 0x21);
}



/////////////////////////////////////////////////////////////////////////////
// Function:    readTemp
// Description: Read the temperature from the sensor
// Arguments:   None
// Return:      Floating point temperature in Celsius
/////////////////////////////////////////////////////////////////////////////
function MPL3115A2::readTemp()
{
    i2c.address(addr);
    local data = i2c.read16(MPL3115A2_OUT_T_MSB);
    if (data & 0x800000)
        data -= 0x1000000;
    
    return data / 256.0;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readPressure
// Description: Read the pressure from the sensor
// Arguments:   None
// Return:      Floating point temperature in Pa
/////////////////////////////////////////////////////////////////////////////
function MPL3115A2::readPressure()
{
    i2c.address(addr);
    local data = i2c.read24(MPL3115A2_OUT_P_MSB);
    if (data & 0x8000)
        data -= 0x10000;

    return data / 64.0;
}

