/*
  LiquidCrystal Library - setCursor
 
 Demonstrates the use a 16x2 & 20x4 LCD display.  The LiquidCrystal
 library works with all LCD displays that are compatible with the 
 Hitachi HD44780 driver. There are many of them out there, and you
 can usually tell them by the 16-pin interface.
 
 This sketch prints to all the positions of the LCD using the
 setCursor(0 method:
 
 The circuit (Esquilo Air to I2C/SPI Backpack with 20x4 Adafruit display:
 * SPI Clock pin to digital pin 13
 * SPI Data pin to digital pin 11
 * SPI Latch pin to digital pin 10
 * +5V and Gnd 
 These pins are not in Adafruit I2C/SPI Backpack implementation
 * LCD RS pin to digital pin 12 (backpack driven - 74LS595 output #1)
 * LCD Enable pin to digital pin 11 (backpack driven - 74LS595 output #2)
 * LCD D4 pin to digital pin 5 (backpack driven - 74LS595 output #6)
 * LCD D5 pin to digital pin 4 (backpack driven - 74LS595 output #5)
 * LCD D6 pin to digital pin 3 (backpack driven - 74LS595 output #4)
 * LCD D7 pin to digital pin 2 (backpack driven - 74LS595 output #3)
 * LCD pin 16 backlight control (backpack driven - 74LS595 output #7)
 * 10K resistor: (on backpack)
 * ends to +5V and ground
 * wiper to LCD VO pin (pin 3) (on backpack)
 
 Library originally added 18 Apr 2008
 by David A. Mellis
 library modified 5 Jul 2009
 by Limor Fried (http://www.ladyada.net)
 example added 9 Jul 2009
 by Tom Igoe 
  modified 25 July 2009
 by David A. Mellis
 converted to Esquilo Air 8/4/2015
 by Gary Wittie
  
 http://www.arduino.cc/en/Tutorial/LiquidCrystal
 */

// include the library code:
dofile("sd:/LIB/DISPLAYS/LiquidCrystal/LiquidCrystalSPI.nut");

// Define SPI0 bus and configuration
spi0 <- SPI(0);	// SPI port 0 (CS=10, MOSI=11, MISO=12, SCK=13)
spi0.select(0);	// Use chip select CS0
spi0.mode(3);		// Inactive high, sample data on Rising edge
//  spi0.speed(10000000);  // default is 10Mbps; 74LS595D can run up to 20Mhz

// initialize the liquid crystal LCD library with the SPI port instance
lcd <- LiquidCrystalSPI(spi0); 
   
// these constants won't change.  But you can change the size of
// your LCD using them:
local numCols = 20;		// this example uses the 20x4 LCD display (16 if 16x2 LCD)
local numRows =  4;		// this example uses the 20x4 LCD display (2 if 16x2 LCD)
local thisLetter = null;
local thisCol = 0;
local thisRow = 0;

lcd.begin(numRows, numCols);

// loop from ASCII 'a' to ASCII 'z':
for (thisLetter = 'a'; thisLetter <= 'z'; thisLetter++) {
  // loop over the columns:
  for (thisRow = 0; thisRow < numRows; thisRow++) {
    // loop over the rows:
    for (thisCol = 0; thisCol < numCols; thisCol++) {
      // set the cursor position:
      lcd.setCursor(thisCol,thisRow);
      // print the letter:
      lcd.write(thisLetter);
      delay(100);
    }
  }
}

