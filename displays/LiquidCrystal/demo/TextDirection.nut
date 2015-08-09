  /*
  LiquidCrystal Library - TextDirection
 
 Demonstrates the use a 16x2 & 20x4 LCD display.  The LiquidCrystal
 library works with all LCD displays that are compatible with the 
 Hitachi HD44780 driver. There are many of them out there, and you
 can usually tell them by the 16-pin interface.
 
 This sketch demonstrates how to use leftToRight() and rightToLeft()
 to move the cursor.
 
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
 converted to Esquilo Air 8/3/2015
 by Gary Wittie 

 http://www.arduino.cc/en/Tutorial/LiquidCrystal
 
 */

require("SPI");

// include the library code:
dofile("sd:/LIB/DISPLAYS/LiquidCrystal/LiquidCrystalSPI.nut");

// Define SPI0 bus and configuration
spi0 <- SPI(0);		// SPI port 0 (CS=10, MOSI=11, MISO=12, SCK=13)
spi0.select(0);		// Use chip select CS0
spi0.mode(3);		// Inactive high, sample data on Rising edge
//  spi0.speed(10000000);  // default is 10Mbps; 74LS595D can run up to 20Mhz

// initialize the liquid crystal LCD library with the SPI port instance
lcd <- LiquidCrystalSPI(spi0); 

local thisChar = 'a';
local charCnt =  0;
local numCols = 20;
local numRows =  4;

// set up the LCD's number of rows and columns: 
lcd.begin(numCols, numRows);

// turn on the cursor:
lcd.cursor();

// Go through two passes of the lower-case characters
for (charCnt = 0; charCnt<26; charCnt++) {
  // reverse directions at 'm':
  if (thisChar == 'm') {
    // go right for the next letter
    lcd.rightToLeft(); 
  }
  // reverse again at 's':
  if (thisChar == 's') {
    // go left for the next letter
    lcd.leftToRight(); 
  }
  // reset at 'z':
  if (thisChar > 'z') {
    // go to (0,0):
    lcd.home(); 
    // start again at 0
    thisChar = 'a';
  }
  // print the character
  lcd.write(thisChar);
  // wait a second:
  delay(500);
  // increment the letter:
  thisChar++;
}

