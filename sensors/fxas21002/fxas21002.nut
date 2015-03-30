/////////////////////////////////////////////////////////////////////////////
// Freescale FXAS21002 gyroscope class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
class FXAS21002
{
    i2c = null;
    addr = 0;
    reg = blob(1);
    data = blob(6);
}

const FXAS21002CQ_STATUS       = 0x00;
const FXAS21002CQ_OUT_X_MSB    = 0x01;
const FXAS21002CQ_F_SETUP      = 0x09;
const FXAS21002CQ_WHOAMI       = 0x0c;
const FXAS21002CQ_CTRL_REG1    = 0x13;
const FXAS21002CQ_CTRL_REG2    = 0x14;
const FXAS21002CQ_CTRL_REG3    = 0x15;

function FXAS21002::constructor(_i2c, _addr)
{
    i2c = _i2c;
    addr = _addr;

    // Initialize the register value for reading data
    reg[0] = FXAS21002CQ_OUT_X_MSB;

    i2c.address(addr);

    // Make sure the FXAS21002 is there
    if (i2c.read8(FXAS21002CQ_WHOAMI) != 0xd7)
        throw("FXAS21002 device not found");
    
	// write 0000 0000 = 0x00 to  control register 1 to place FXAS21002CQ into
    // standby
    // [7-2] = 0000 00
    // [1]: active=0: standby
    // [0]: ready=0: standby
    i2c.write8(FXAS21002CQ_CTRL_REG1, 0x0);
    
    // write 0100 0000 = 0x00 to FIFO register
    // standby
    // [7-6] = 01: FIFO circular buffer
    // [5-0] = 000001: watermark at 1 sample
    i2c.write8(FXAS21002CQ_F_SETUP, 0x41);
    
    // write 0001 0010 = 0x16 to control register 1
    // [7]: reserved
    // [6]: rst=0: no software reset
    // [5]: st=0: no self-test enable
    // [4-2]: dr=100=4: 25 Hz output data bandwidth
    // [1]: active=1: gyroscope active mode
    // [0]: ready=0: don't care in active mode
    i2c.write8(FXAS21002CQ_CTRL_REG1, 0x12);
}

function FXAS21002::readblob()
{
    i2c.address(addr);
    i2c.xfer(reg, data);
    
    return data;
}

function FXAS21002::count()
{
    i2c.address(addr);
    return i2c.read8(FXAS21002CQ_STATUS) & 0x3f;
}

function FXAS21002::read()
{
    local mag = {};
    
    i2c.address(addr);
    i2c.xfer(reg, data);
    
    data.seek(0);
    data.swap2();
    mag.x <- data.readn('s') * 0.00109083078;
    mag.y <- data.readn('s') * 0.00109083078;
    mag.z <- data.readn('s') * 0.00109083078;
    
    return mag;
}

