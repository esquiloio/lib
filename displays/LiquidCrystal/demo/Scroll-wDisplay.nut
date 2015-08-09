/*
  LiquidCrystal Library - scrollDisplayLeft() and scrollDisplayRight()
  LiquidCrystal Library - display() and noDisplay()
 
 Demonstrates the use a 16x2 & 20x4 LCD display.  The LiquidCrystal
 library works with all LCD displays that are compatible with the 
 Hitachi HD44780 driver. There are many of them out there, and you
 can usually tell them by the 16-pin interface.
 
 This sketch prints "Hello World!" to the LCD and uses the
 scrollDisplayLeft() and scrollDisplayRight() methods to scroll
 the text.

 This sketch prints "Hello World!" to the LCD and uses the 
 display() and noDisplay() functions to turn on and off
 the display.
 
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

require("SPI");

// include the library code:
dofile("sd:/LIB/DISPLAYS/LiquidCrystal/LiquidCrystalSPI.nut");

// Define SPI0 bus and configuration
spi0 <- SPI(0);	// SPI port 0 (CS=10, MOSI=11, MISO=12, SCK=13)
spi0.select(0);	// Use chip select CS0
spi0.mode(3);		// Inactive high, sample data on Rising edge
//  spi0.speed(10000000);  // default is 10Mbps; 74LS595D can run up to 20Mhz

// initialize the liquid crystal LCD library with the SPI port instance
lcd <- LiquidCrystalSPI(spi0); 

// variable definitions
local positionCounter = 0;
local numCols = 20;
local numRows =  4;

// set up the LCD's number of rows and columns: 
lcd.begin(numCols, numCols);
// lcd.setCursor(0,7);
// Print a message to the LCD.
lcd.print("hello, world!");
delay(1000);

// scroll 13 positions (string length) to the left 
// to move it offscreen left:
for (positionCounter = 0; positionCounter < 13; positionCounter++) {
  // scroll one position left:
  lcd.scrollDisplayLeft(); 
  // wait a bit:
  delay(300);
}

// scroll 33 positions (string length + display length) to the right
// to move it offscreen right:
for (positionCounter = 0; positionCounter < (numCols+13); positionCounter++) {
  // scroll one position right:
  lcd.scrollDisplayRight(); 
  // wait a bit:
  delay(300);
}
  
// scroll 20 positions (display length + string length) to the left
// to move it back to center:
for (positionCounter = 0; positionCounter < numCols; positionCounter++) {
  // scroll one position left:
  lcd.scrollDisplayLeft(); 
  // wait a bit:
  delay(300);
}
  
// delay at the end of the full loop:
 delay(1000);  // no loop in this example

// Turn off the display:
lcd.noDisplay();
delay(1000);

// Turn on the display:
lcd.display();
delay(500);

