/*
 LiquidCrystalSPI Basic Demo (20x4 or 16x2 LCD Display with Adafruit Backpack-SPI mode enabled)

 Demonstrates the use a 20x4 or 16x2 LCD display.  The LiquidCrystal
 library works with all LCD displays that are compatible with the 
 Hitachi HD44780 driver. There are many of them out there, and you
 can usually tell them by the 16-pin interface.
 
 The display will be written on all 4 lines with dummy text.  The last
 line has the degree symbol with a fake temperature.  The temperature
 value is updated with a new value using the setCursor command to point to it.
 
 The circuit (Esquilo Air to I2C/SPI Backpack with 20x4 or 16x2 Adafruit display):
 * SPI Clock pin to digital pin 13
 * SPI Data pin to digital pin 11
 * SPI Latch pin to digital pin 10
 * +5V and Gnd 
 These pins are part of the Adafruit I2C/SPI Backpack implementation
 * LCD RS pin (backpack driven - 74LS595 output #1)
 * LCD Enable pin (backpack driven - 74LS595 output #2)
 * LCD D4 pin (backpack driven - 74LS595 output #6)
 * LCD D5 pin (backpack driven - 74LS595 output #5)
 * LCD D6 pin (backpack driven - 74LS595 output #4)
 * LCD D7 pin (backpack driven - 74LS595 output #3)
 * LCD backlight control pin (backpack driven - 74LS595 output #7)
 * +5V and ground
 * wiper to LCD VO pin (pin 3) (on backpack)
*/ 

require("SPI");

// include the LiquidCrystal library code:
dofile("sd:/LIB/DISPLAYS/LiquidCrystal/LiquidCrystalSPI.nut");

// Define SPI0 bus instance and configuration
spi0 <- SPI(0);	// SPI port 0 (CS=10, MOSI=11, MISO=12, SCK=13)
spi0.select(0);	// Use chip select CS0
spi0.mode(3);		// Inactive high, sample data on rising edge
//  spi0.speed(10000000);  // default is 10Mbps; 74LS595D can run up to 20Mhz

lcd  <- LiquidCrystalSPI(spi0); 

local numCols = 20;
local numRows =  4;
local currRow =  0;

// Define the LCD column and row values for a 20x4 LCD display
lcd.begin(numCols, numRows);

lcd.clear();         // cursor position set to 0,0 by default
//lcd.noCursor();      // do not display the cursor
currRow = 0;
lcd.print("Test for Line 1");
lcd.setCursor(0, 1);
currRow = 1;
if (numRows > 2) {
  lcd.print("Test for Line 2");
  lcd.setCursor(0, 2);
  currRow = 2;
}
if (numRows > 3) {
  lcd.print("Test for Line 3");
  lcd.setCursor(0, 3);
  currRow = 3;
}
lcd.print("Temp = 75.2");
lcd.write(0xDF);
lcd.print("F");
delay(2000);
lcd.setCursor(7,currRow);
lcd.print("82.1");


