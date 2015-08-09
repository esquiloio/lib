//
// LiquidCrystalSPI library on Esquilo-Air (SPI only, not I2C or parallel pins)
//
// Demonstrates the use a 16x2 or 20x4 LCD display connected to the Esquilo Air
// though the Adafruit I2C/SPI LCD Backpack in the SPI configuration.  This 
// LiquidCrystal library works with all LCD displays that are compatible with the 
// Hitachi HD44780 driver. There are many of them out there, and you
// can usually tell them by the 16-pin interface.  This backpack uses the 74LS595D
// serial to parallel converter connected to the SPI pins; SCK, MOSI, & SS(CS).
//
// Library originally added 18 Apr 2008
// by David A. Mellis
// library modified 5 Jul 2009
// by Limor Fried (http://www.ladyada.net)
// example added 9 Jul 2009
// by Tom Igoe 
// modified 25 July 2009
// by David A. Mellis
// converted to Esquilo Air 8/6/2015
// by Gary Wittie 
//
// http://www.arduino.cc/en/Tutorial/LiquidCrystal
//
// User example:
// spi0 <- SPI(0);      // port 0 uses pins 10,11,12,13
// lcd <- LiquidCrystalSPI(spi0);  // initialize SPI interface library
// lcd.begin(20,4);     // initilize columns and rows
// lcd.setcursor(0,0);  // set cursor position col,row
// lcd.print(string);   // output string on LCD display
//
//

class LiquidCrystalSPI
{
  displayfunction = 0;
  displaycontrol = 0;
  displaymode = 0;

  numlines = 0;
  currline = 0;
  cols = 0;
  lines = 0;

  SPIbuff = blob(1);
  spiDataPin = null;
  spiClockPin = null;
  spiLatchPin = null;
  sdp = 0;
  scp = 0;
  slp = 0;
  spi = null;

 // SPI (74LS595) Expander pin assignments on I2C/SPI LCD Backpack from Adafruit
 // I2C interface on this backpack uses the MCP23008 IC.
  rs_pin = 1;
  rw_pin = 255;
  enable_pin = 2;
  data_pins = blob(4);  // see begin function for pin assigments

// commands
  LCD_CLEARDISPLAY = 0x01;
  LCD_RETURNHOME = 0x02;
  LCD_ENTRYMODESET = 0x04;
  LCD_DISPLAYCONTROL = 0x08;
  LCD_CURSORSHIFT = 0x10;
  LCD_FUNCTIONSET = 0x20;
  LCD_SETCGRAMADDR = 0x40;
  LCD_SETDDRAMADDR = 0x80;

// flags for display entry mode
  LCD_ENTRYRIGHT = 0x00;
  LCD_ENTRYLEFT = 0x02;
  LCD_ENTRYSHIFTINCREMENT = 0x01;
  LCD_ENTRYSHIFTDECREMENT = 0x00;

// flags for display on/off control
  LCD_DISPLAYON = 0x04;
  LCD_DISPLAYOFF = 0x00;
  LCD_CURSORON = 0x02;
  LCD_CURSOROFF = 0x00;
  LCD_BLINKON = 0x01;
  LCD_BLINKOFF = 0x00;

// flags for display/cursor shift
  LCD_DISPLAYMOVE = 0x08;
  LCD_CURSORMOVE = 0x00;
  LCD_MOVERIGHT = 0x04;
  LCD_MOVELEFT = 0x00;

// flags for function set
  LCD_8BITMODE = 0x10;
  LCD_4BITMODE = 0x00;
  LCD_2LINE = 0x08;
  LCD_1LINE = 0x00;
  LCD_5x10DOTS = 0x04;
  LCD_5x8DOTS = 0x00;
  LSBFIRST = 0x00;
  MSBFIRST = 0x01;
    
 constructor(_spi) {
  spi = _spi;		// set SPI port definition

  // Will always use 4bit mode for LCD display backpack
  displayfunction = LCD_4BITMODE | LCD_2LINE | LCD_5x8DOTS;
 
  // we can't begin() yet :(
  begin(16,2);  // dummy run to setup display
  init(16,2);   // Run work-around code for startup issues on powerup
}

// When the display powers up, it is configured as follows:
//
// 1. Display clear
// 2. Function set: 
//    DL = 0 -> 4-bit interface data (1 -> 8-bit interface data) 
//    N = 0 -> 1-line display; 1 -> 2 or more line display
//    F = 0 -> 5x8 dot character font 
// 3. Display on/off control: 
//    D = 0 -> Display off 
//    C = 0 -> Cursor off 
//    B = 0 -> Blinking off 
// 4. Entry mode set: 
//    I/D = 1 -> Increment by 1 
//    S = 0 -> No shift 
//
// Note, however, that resetting the Esquilo doesn't reset the LCD, so we
// can't assume that its in that state when a nut starts (and the
// LiquidCrystalSPI constructor is called).
}


function LiquidCrystalSPI::begin( _cols, _lines) {

//  init();
  // Assume always in SPI mode (74LS595D outputs)
  SPIbuff[0] = 0x80; // backlight
  data_pins[0] = 6;  // really D4
  data_pins[1] = 5;  // really D5
  data_pins[2] = 4;  // really D6
  data_pins[3] = 3;  // really D7

  if (_lines > 1) {
    displayfunction = displayfunction | LCD_2LINE;
  }
  numlines = _lines;
  currline = 0;

  // SEE PAGE 45/46 FOR INITIALIZATION SPECIFICATION!
  // according to datasheet, we need at least 40ms after power rises above 2.7V
  // before sending commands. Esquilo can turn on way before 4.5V so we'll wait 50

//  udelay(50000); 
  udelay(5000); 

  // Now we pull both RS and R/W low to begin commands (enable will toggle high/low)
  _buildData(rs_pin, LOW);
//  _digitalWrite();
  _buildData(enable_pin, LOW);
  _digitalWrite();             // output rs_pin and enable_pin low states together
  if (rw_pin != 255) { 
    _buildData(rw_pin, LOW);   // rw_pin not used in this backpack/LCD display
    _digitalWrite();
  }
  
  //put the LCD into 4 bit mode
  // this is according to the hitachi HD44780 datasheet
  // page 45 figure 23
    
  command(LCD_FUNCTIONSET | displayfunction);    // Send function set command sequence
  udelay(4500);                       // wait more than 4.1ms

  command(LCD_FUNCTIONSET | displayfunction);    // second try
  udelay(150);
  
  command(LCD_FUNCTIONSET | displayfunction);    // third go
  command(LCD_FUNCTIONSET | displayfunction);      // finally, set # lines, font size, etc.

  // turn the display on with no cursor or blinking default
  displaycontrol = LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF;  
  display();

  // clear it off
  clear();

  // Initialize to default text direction (for romance languages)
  displaymode = LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT;
  // set the entry mode
  command(LCD_ENTRYMODESET | displaymode);
}

// Functional work-around to get the Adafruit I2C/SPI Backpack
// to properly received the command and character writes at 
// power-up.  This code was taken from the setCursor.nut demo.
function LiquidCrystalSPI::init(_cl, _rw)
{
  noDisplay();
  local tempChar = ' ';
  for (local drow=0; drow<_rw; drow++) {
    for (local dcol=0; dcol<_cl; dcol++) {
        setCursor(dcol,drow);
        write(tempChar);
        delay(20);
    }
  }
  clear();
  display();
}


/********** high level commands, for the user! */
function LiquidCrystalSPI::clear()
{
  command(LCD_CLEARDISPLAY);  // clear display, set cursor position to zero
  udelay(2000);  // this command takes a long time!
}

function LiquidCrystalSPI::home()
{
  command(LCD_RETURNHOME);  // set cursor position to zero
  udelay(2000);  // this command takes a long time!
}

function LiquidCrystalSPI::setCursor(_col, _row)
{
  local row = 0;
  local col = 0;
  col = _col;
  row = _row;
  local row_offsets = blob(4);
  row_offsets[0] = 0x00;
  row_offsets[1] = 0x40;
  row_offsets[2] = 0x14;
  row_offsets[3] = 0x54;
  if ( row > numlines ) {
    row = numlines-1;    // we count rows starting w/0
  }
  
  command(LCD_SETDDRAMADDR | (col + row_offsets[row]));
}

// Turn the display on/off (quickly)
function LiquidCrystalSPI::noDisplay() {
  displaycontrol = displaycontrol & ~LCD_DISPLAYON;
  command(LCD_DISPLAYCONTROL | displaycontrol);
}
function LiquidCrystalSPI::display() {
  displaycontrol = displaycontrol | LCD_DISPLAYON;
  command(LCD_DISPLAYCONTROL | displaycontrol);
}

// Turns the underline cursor on/off
function LiquidCrystalSPI::noCursor() {
  displaycontrol = displaycontrol & ~LCD_CURSORON;
  command(LCD_DISPLAYCONTROL | displaycontrol);
}
function LiquidCrystalSPI::cursor() {
  displaycontrol = displaycontrol | LCD_CURSORON;
  command(LCD_DISPLAYCONTROL | displaycontrol);
}

// Turn on and off the blinking cursor
function LiquidCrystalSPI::noBlink() {
  displaycontrol = displaycontrol & ~LCD_BLINKON;
  command(LCD_DISPLAYCONTROL | displaycontrol);
}
function LiquidCrystalSPI::blink() {
  displaycontrol = displaycontrol | LCD_BLINKON;
  command(LCD_DISPLAYCONTROL | displaycontrol);
}

// These commands scroll the display without changing the RAM
function LiquidCrystalSPI::scrollDisplayLeft() {
  command(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVELEFT);
}
function LiquidCrystalSPI::scrollDisplayRight() {
  command(LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVERIGHT);
}

// This is for text that flows Left to Right
function LiquidCrystalSPI::leftToRight() {
  displaymode = displaycontrol | LCD_ENTRYLEFT;
  command(LCD_ENTRYMODESET | displaymode);
}

// This is for text that flows Right to Left
function LiquidCrystalSPI::rightToLeft() {
  displaymode = displaycontrol & ~LCD_ENTRYLEFT;
  command(LCD_ENTRYMODESET | displaymode);
}

// This will 'right justify' text from the cursor
function LiquidCrystalSPI::autoscroll() {
  displaymode = displaycontrol | LCD_ENTRYSHIFTINCREMENT;
  command(LCD_ENTRYMODESET | displaymode);
}

// This will 'left justify' text from the cursor
function LiquidCrystalSPI::noAutoscroll() {
  displaymode = displaycontrol & ~LCD_ENTRYSHIFTINCREMENT;
  command(LCD_ENTRYMODESET | displaymode);
}

// Allows us to fill the first 8 CGRAM locations
// with custom characters
function LiquidCrystalSPI::createChar(_location, _charmap) {
  local location = _location;
  location = location & 0x7; // we only have 8 locations 0-7
  command(LCD_SETCGRAMADDR | (location << 3));
  for (local i=0; i<8; i++) {
    write(charmap[i]);
  }
}

/*********** mid level commands, for sending data/cmds */

function LiquidCrystalSPI::command(_value) {
  send(_value, LOW);
}

function LiquidCrystalSPI::write(_value) {
  send(_value, HIGH);
}

/************ low level data pushing commands **********/

// little wrapper for i/o writes
function LiquidCrystalSPI::_digitalWrite() {
    spi.write(SPIbuff);  // assume CS0 is controlled in write command
}

// Construct the data byte to send to 74LS595D and then to display driver
function LiquidCrystalSPI::_buildData(_p, _d) {
  if (_d == HIGH) 
     SPIbuff[0] = SPIbuff[0] | (1 << _p);
   else 
     SPIbuff[0] = SPIbuff[0] & ~(1 << _p);
}

// Allows to set the backlight, if the LCD backpack is used
function LiquidCrystalSPI::setBacklight(_status) {
  _buildData(7, _status);    // build SPIbuff data
  _digitalWrite();           // backlight is on pin 7
}

// write either command or data, with automatic 4/8-bit selection
function LiquidCrystalSPI::send(_value, _mode) {
  _buildData(rs_pin, _mode);  // build SPIbuff data with command call
//  _digitalWrite();      // Set mode on rs_pin (0=command,1=data)

  write4bits(_value>>4);  // shift upper nibble to lower space for processing
  write4bits(_value);     // use lower nibble for processing
}

// Main interface for outputing data in a string or integer for the display
function LiquidCrystalSPI::print(str) {
  local stt = typeof str;
  if (stt == "string") {		// string parsing to output each character
    local sLen = str.len();
    local buffer = blob(sLen);
    buffer.writestr(str);		// put string into buffer for transfer
    for (local i=0; i<sLen; i++) {
     // _digitalWrite(buffer[i],HIGH);
      write(buffer[i]);
    }
  } else {
      write(str);			// output a single character
  }
}

// toggle enable_pin on backpack to set value on bus to lcd display
function LiquidCrystalSPI::pulseEnable() {
  _buildData(enable_pin, LOW);	// build SPIbuff data
  _digitalWrite();
  udelay(1);    
  _buildData(enable_pin, HIGH);	// build SPIbuff data
  _digitalWrite();
  udelay(1);		// enable pulse must be >450ns
  _buildData(enable_pin, LOW);	// build SPIbuff data
  _digitalWrite();
  udelay(100);	// commands need > 37us to settle
}

function LiquidCrystalSPI::write4bits(_value) {
  // Assume SPI only interface; removed I2C code
  for (local i = 0; i < 4; i++) {
    _buildData(data_pins[i], (_value >> i) & 0x01);
  }
//  _digitalWrite();  // send final SPIbuff data
  pulseEnable();    // toggle enable pin on backpack to latch data in LCD
}

// 8-bit writes not supported with SPI and the Adafruit I2C/SPI LCD Backpack
//function LiquidCrystalSPI::write8bits(_value) {
//  for (int i = 0; i < 8; i++) {
//    _digitalWrite(data_pins[i], (_value >> i) & 0x01);
//  }
//  pulseEnable();

//  spiLatchPin.low();
//  shiftOut(MSBFIRST, _value, 8);
//  spiLatchPin.high();
//}

