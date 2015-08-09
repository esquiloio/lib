// Real-Time-Clock DS1307RTC Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
require("I2C");

dofile("sd:/lib/clocks/DS1307RTC/DS1307RTC.nut");

// Use I2C0 bus
i2c <- I2C(0);

// Create tm array to hold date/time objects
 local tm = { Second=0, Minute=0, Hour=0, Wday=0, Day=0, Month=0, Year=0 };
 local initFlag = false;

// Create our sensor objects
rtc <- DS1307RTC(i2c, 0x68);

if (initFlag) {
  // Write date and time to initialize RTC from tm array
  tm.Second=0; tm.Minute=15; tm.Hour=15; tm.Month=7; tm.Day=12; tm.Year=2015; tm.Wday=7;
  rtc.write(tm);
}

// Read date and time from RTC into tm array
tm = rtc.read();

print("RTC date and time!\n");
print(" -> month  = "+tm.Month+"\n");
print(" -> day    = "+tm.Day+"\n");
print(" -> year   = "+tm.Year+"\n");
print(" -> wkday  = "+tm.Wday+"\n\n");
print(" -> hour   = "+tm.Hour+"\n");
print(" -> minute = "+tm.Minute+"\n");
print(" -> second = "+tm.Second+"\n\n");

print("Date and Time String:\n");
print(tm.Month+"/"+tm.Day+"/"+tm.Year+" "+tm.Hour+":"+tm.Minute+":"+tm.Second+"\n");



