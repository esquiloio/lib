/////////////////////////////////////////////////////////////////////////////
// Freescale FXOS8700 accelerometer and magnetometer class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
class FXOS8700
{
    i2c = null;
    addr = 0;
    reg = blob(1);
    data = blob(6);
}

const FXOS8700CQ_STATUS       = 0x00;
const FXOS8700CQ_OUT_X_MSB    = 0x01;
const FXOS8700CQ_F_SETUP      = 0x09;
const FXOS8700CQ_WHOAMI       = 0x0d;
const FXOS8700CQ_XYZ_DATA_CFG = 0x0e;
const FXOS8700CQ_CTRL_REG1    = 0x2a;
const FXOS8700CQ_M_DR_STATUS  = 0x32;
const FXOS8700CQ_M_OUT_X_MSB  = 0x33;
const FXOS8700CQ_M_CTRL_REG1  = 0x5b;
const FXOS8700CQ_M_CTRL_REG2  = 0x5c;

function FXOS8700::constructor(_i2c, _addr)
{
    i2c = _i2c;
	addr = _addr;
    
    i2c.address(addr);

    // Make sure the FXOS8700 is there
    if (i2c.read8(FXOS8700CQ_WHOAMI) != 0xc7)
        throw("FXOS8700 device not found");
    
	// write 0000 0000 = 0x00 to accelerometer control register 1 to place FXOS8700CQ into
    // standby
    // [7-1] = 0000 000
    // [0]: active=0
    i2c.write8(FXOS8700CQ_CTRL_REG1, 0x0);
    
    // write 0100 0000 = 0x00 to accelerometer FIFO register
    // standby
    // [7-6] = 01: FIFO circular buffer
    // [5-0] = 000001: watermark at 1 sample
    i2c.write8(FXOS8700CQ_F_SETUP, 0x41);
    
    // write 1001 1111 = 0x9F to magnetometer control register 1
    // [7]: m_acal=1: auto calibration enabled
    // [6]: m_rst=0: no one-shot magnetic reset
    // [5]: m_ost=0: no one-shot magnetic measurement
    // [4-2]: m_os=111=7: 16x oversampling (for 50Hz) to reduce magnetometer noise
    // [1-0]: m_hms=11=3: select hybrid mode with accel and magnetometer active
    i2c.write8(FXOS8700CQ_M_CTRL_REG1, 0x9f);

    // write 0010 0000 = 0x20 to magnetometer control register 2
    // [7]: reserved
    // [6]: reserved
    // [5]: hyb_autoinc_mode=1 to map the magnetometer registers to follow the 
    // accelerometer registers
    // [4]: m_maxmin_dis=0 to retain default min/max latching even though not used
    // [3]: m_maxmin_dis_ths=0
    // [2]: m_maxmin_rst=0
    // [1-0]: m_rst_cnt=00 to enable magnetic reset each cycle
    i2c.write8(FXOS8700CQ_M_CTRL_REG2, 0x20);
    
    // write 0000 0001= 0x01 to XYZ_DATA_CFG register
    // [7]: reserved
    // [6]: reserved
    // [5]: reserved
    // [4]: hpf_out=0
    // [3]: reserved
    // [2]: reserved
    // [1-0]: fs=01 for accelerometer range of +/-4g range with 0.488mg/LSB
    i2c.write8(FXOS8700CQ_XYZ_DATA_CFG, 0x01);
	    
    // write 0001 1101 = 0x25 to accelerometer control register 1
    // [7-6]: aslp_rate=00
    // [5-3]: dr=011 for 100Hz data rate (50Hz in hybrid mode)
    // [2]: lnoise=1 for low noise mode
    // [1]: f_read=0 for normal 16 bit reads
    // [0]: active=1 to take the part out of standby and enable sampling
    i2c.write8(FXOS8700CQ_CTRL_REG1, 0x1d);
}

function FXOS8700::accel_readblob()
{
    reg[0] = FXOS8700CQ_OUT_X_MSB;
    i2c.address(addr);
    i2c.xfer(reg, data);
    
    return data;
}

function FXOS8700::mag_readblob()
{
    reg[0] = FXOS8700CQ_M_OUT_X_MSB;
    i2c.address(addr);
    i2c.xfer(reg, data);
    
    return data;
}

function FXOS8700::accel_count()
{
    i2c.address(addr);
    return i2c.read8(FXOS8700CQ_STATUS) & 0x3f;
}

function FXOS8700::mag_count()
{
    i2c.address(addr);
    return (i2c.read8(FXOS8700CQ_M_DR_STATUS) & 080 ? 1 : 0);
}

function FXOS8700::accel_read()
{
    local accel = {};
    
    reg[0] = FXOS8700CQ_OUT_X_MSB;

    i2c.address(addr);
    i2c.xfer(reg, data);
    
    data.seek(0);
    data.swap2();
    accel.x <- (data.readn('s') >> 2) / 2048.0;
    accel.y <- (data.readn('s') >> 2) / 2048.0;
    accel.z <- (data.readn('s') >> 2) / 2048.0;

    return accel;
}

function FXOS8700::mag_read()
{
    local mag = {};
    
    reg[0] = FXOS8700CQ_M_OUT_X_MSB;

    i2c.address(addr);
    i2c.xfer(reg, data);
    
    data.seek(0);
    data.swap2();
    mag.x <- data.readn('s');
    mag.y <- data.readn('s');
    mag.z <- data.readn('s');

    return mag;
}
