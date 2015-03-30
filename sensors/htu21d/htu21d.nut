/////////////////////////////////////////////////////////////////////////////
// Measurement Specialties HTU21D humidity sensor class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
class HTU21D
{
    constructor(_i2c, _addr)
    {
        i2c = _i2c;
        addr = _addr; 
    }

    i2c = null;
    addr = 0;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readTemp
// Description: Read the ambient temperature from the sensor
// Arguments:   None
// Return:      Floating point temperature in Celsius
/////////////////////////////////////////////////////////////////////////////
function HTU21D::readTemp()
{
    i2c.address(addr);
    local temp = i2c.read24(0xe3) >> 8;
    temp = -46.85 + 175.75 * temp / 65536.0;
    
    return temp;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    readHumidity
// Description: Read the humidity from the sensor
// Arguments:   None
// Return:      Floating point humidity in percentage
/////////////////////////////////////////////////////////////////////////////
function HTU21D::readHumidity() {
    i2c.address(addr);
    local humidity = i2c.read24(0xe5) >> 8;
    humidity = -6.0 + 125.0 * humidity / 65536.0;
    
    return humidity;
}
