/*
 * DS1307RTC - library for DS1307 RTC
  
  Copyright (c) Michael Margolis 2009
  This library is intended to be uses with Arduino Time.h library functions

  The library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Lesser General Public
  License as published by the Free Software Foundation; either
  version 2.1 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
  
  30 Dec 2009 - Initial release
  5 Sep 2011 updated for Arduino 1.0
  8 Aug 2015 - converted to Esquilo Air by Gary Wittie
 */

// Example Usage:
// Use I2C0 bus
// i2c <- I2C(0);
// Create our sensor objects
// rtc <- DS1307RTC(i2c, 0x68);

class DS1307RTC {
  // DS1307_CTRL_ID = 0x68;
  constructor(_i2c, _addr) {
    i2c = _i2c;
    addr = _addr;
  }
  i2c = null;
  addr = 0;
  tm = { Second=0, Minute=0, Hour=0, Wday=0, Day=0, Month=0, Year=0 };

}

// PUBLIC FUNCTIONS
//////////////////////////////////////////////////////////////
// Function:	get
// Description:	Read date/time from the RTC
// Arguments:	None
// Return:	date/time in tmElements array
//////////////////////////////////////////////////////////////
function DS1307RTC::get()   // Aquire data from buffer and convert to time_t
{
  if (read() == false) return 0;
  return(tm);
}

//////////////////////////////////////////////////////////////
// Function:	set
// Description:	Write date/time to the RTC
// Arguments:	time in time_t format
// Return:	true if successful
//////////////////////////////////////////////////////////////
function DS1307RTC::set(t)
{
  i2c.address(addr);
  t.Second = t.second | 0x80;  // stop the clock 
  write(t); 
  t.Second = t.Second & 0x7f;  // start the clock
  write(t); 
}

//////////////////////////////////////////////////////////////
// Function:	read
// Description:	Read date/time from the RTC in BCD format
// Arguments:	date/time in tmElements array
// Return:	true if successful
//////////////////////////////////////////////////////////////
// Aquire data from the RTC chip in BCD format
function DS1307RTC::read()
{
  local sec;

  i2c.address(addr);
  sec = i2c.read8(0x00);                       // register addr 0
  tm.Second = bcd2dec(sec & 0x7f);
  tm.Minute = bcd2dec(i2c.read8(0x01) );       // register addr 1
  tm.Hour =   bcd2dec(i2c.read8(0x02) & 0x3f); // mask assumes 24hr clock,addr 2
  tm.Wday = bcd2dec(i2c.read8(0x03) );         // register addr 3
  tm.Day = bcd2dec(i2c.read8(0x04) );          // register addr 4
  tm.Month = bcd2dec(i2c.read8(0x05) );        // register addr 5
  tm.Year = bcd2dec(i2c.read8(0x06));          // register addr 6
  tm.Year = y2kYearToTm(tm.Year);              // convert year to 4 digits
  return tm;
}

//////////////////////////////////////////////////////////////
// Function:	write
// Description:	Write date/time to the RTC
// Arguments:	date/time in tmElements array
// Return:	pass if successful
//////////////////////////////////////////////////////////////
function DS1307RTC::write(tmArray)
{
  tm = clone tmArray;
  i2c.address(addr);
  i2c.write8(0x00,0x80);  // turn off clock
  i2c.write8(0x01,dec2bcd(tm.Minute));
  i2c.write8(0x02,dec2bcd(tm.Hour));      // sets 24 hour format
  i2c.write8(0x03,dec2bcd(tm.Wday));   
  i2c.write8(0x04,dec2bcd(tm.Day));
  i2c.write8(0x05,dec2bcd(tm.Month));
  if (tm.Year > 99) {
    local tmY = tmYearToY2k(tm.Year);
    print("writeRTC (year>99): "+tm.Year+"; adjusted yr="+tmY+"\n");
    i2c.write8(0x06,dec2bcd(tmYearToY2k(tm.Year))); 
  } else {
    i2c.write8(0x06,dec2bcd(tm.Year)); 
  }
  i2c.write8(0x00,dec2bcd(tm.Second&0x7F)); // set seconds and turn on clock

  return true;
}

// PRIVATE FUNCTIONS

//////////////////////////////////////////////////////////////
// Function:	dec2bcd
// Description:	Convert decimal number to BCD number
// Arguments:	Decimal number
// Return:	BCD format number
//////////////////////////////////////////////////////////////
// Convert Decimal to Binary Coded Decimal (BCD)
function DS1307RTC::dec2bcd(num)
{
  local bcdnum = blob(1);  // force to 8bit integer
  bcdnum[0] = ((num/10 * 16) + (num % 10));
  return bcdnum[0];
}

//////////////////////////////////////////////////////////////
// Function:	bcd2dec
// Description:	Convert bcd number to decimal number
// Arguments:	BCD number
// Return:	Decimal number
//////////////////////////////////////////////////////////////
// Convert Binary Coded Decimal (BCD) to Decimal
function DS1307RTC::bcd2dec(num)
{
  local decnum = blob(1);  // force to 8bit integer
  decnum[0] = ((num/16 * 10) + (num % 16));
  return decnum[0];
}

//////////////////////////////////////////////////////////////
// Function:	y2kYearToTm
// Description:	Convert number to 4 digit year number
// Arguments:	BCD number
// Return:	Decimal number
//////////////////////////////////////////////////////////////
// 
function DS1307RTC::y2kYearToTm(num)
{
  //convenience macros to convert to and from tm years 
  local _y2kYearToTm      = (num + 2000)   

  return _y2kYearToTm;
}

//////////////////////////////////////////////////////////////
// Function:	tmYearToY2k
// Description:	Convert number to 4 digit year number
// Arguments:	BCD number
// Return:	Decimal number
//////////////////////////////////////////////////////////////
// 
function DS1307RTC::tmYearToY2k(num)
{
  //convenience macros to convert to and from tm years 
 local _tmYearToY2k      = (num - 2000)    // offset is from 2000

  return _tmYearToY2k;
}

