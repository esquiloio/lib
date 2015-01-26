/////////////////////////////////////////////////////////////////////////////
// Microchip MCP9808 temperature sensor class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
class MCP9808
{
  constructor(_i2c, _addr)
  {
    i2c = _i2c;
    addr = 0x18 + _addr; 
  }
  
  i2c = null;
  addr = 0;
  reg = blob(1);
  data = blob(2);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    temp
// Description: Read the ambient temperature from the sensor
// Arguments:   None
// Return:      Floating point temperature in Celsius
/////////////////////////////////////////////////////////////////////////////
function MCP9808::temp()
{
  reg[0] = 0x5;
  i2c.address(addr);
  i2c.xfer(reg, data);
  
  local temp = ((data[0] & 0xf) * 16.0 + data[1] / 16.0);
  
  if (data[0] & 0x10)
    temp = temp - 256.0;
  
  return temp;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    revision
// Description: Read the device revision number
// Arguments:   None
// Return:      Integer revision number
/////////////////////////////////////////////////////////////////////////////
function MCP9808::revision()
{
  reg[0] = 0x7;
  i2c.address(addr);
  i2c.xfer(reg, data);

  return data[1];
}
