/////////////////////////////////////////////////////////////////////////////
// JHD1214 I2C LCD class
//
// Ported from:
//   https://github.com/Seeed-Studio/Grove_LCD_RGB_Backlight
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Example usage:
//
// local lcd = JHD1214(I2C(0), 0x3E);
// lcd.setCursor(8,0);
// lcd.write("Hello World!");
// delay(1000);
// lcd.off();
// delay(1000);
// lcd.on();
//
require("I2C");

const JHD1214_COLUMNS = 16;
const JHD1214_ROWS    = 2;

const JHD1214_CLEARDISPLAY         = 0x01;

const JHD1214_ENTRYMODESET         = 0x04;
const JHD1214_ENTRYLEFT            = 0x02;
const JHD1214_ENTRYRIGHT           = 0x00;
const JHD1214_ENTRYSHIFTINCREMENT  = 0x01;
const JHD1214_ENTRYSHIFTDECREMENT  = 0x00;

const JHD1214_DISPLAYCONTROL       = 0x08;
const JHD1214_DISPLAYON            = 0x04;
const JHD1214_DISPLAYOFF           = 0x00;
const JHD1214_CURSORON             = 0x02;
const JHD1214_CURSOROFF            = 0x00;
const JHD1214_BLINKON              = 0x01;
const JHD1214_BLINKOFF             = 0x00;

const JHD1214_FUNCTIONSET          = 0x20;
const JHD1214_5x10DOTS             = 0x04;
const JHD1214_5x8DOTS              = 0x00;
const JHD1214_1LINE                = 0x00;
const JHD1214_2LINE                = 0x08;
const JHD1214_8BITMODE             = 0x10;
const JHD1214_4BITMODE             = 0x00;

class JHD1214
{
    _i2c     = null;
    _address = null;
    _row     = null;
    _column  = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    Class Constructor
// Description: Create
// Arguments:   _i2c - I2C object to control the display
/////////////////////////////////////////////////////////////////////////////
function JHD1214::constructor(i2c, address)
{
    _i2c     = i2c;
    _address = address;

    // Wait at least 30ms after power up, per datasheet
    delay(50);

    for (local i = 0; i < 3; i++) {
    _command(JHD1214_FUNCTIONSET | JHD1214_2LINE);
    delay(10);
}

    on();

    clear();

    _command(JHD1214_ENTRYMODESET | JHD1214_ENTRYLEFT | JHD1214_ENTRYSHIFTDECREMENT);

    setCursor(0, 0);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    on
// Description: Turns display on
/////////////////////////////////////////////////////////////////////////////
function JHD1214::on()
{
    _command(JHD1214_DISPLAYCONTROL | JHD1214_DISPLAYON | JHD1214_CURSOROFF
        | JHD1214_BLINKOFF);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    off
// Description: Turns display off
/////////////////////////////////////////////////////////////////////////////
function JHD1214::off()
{
    _command(JHD1214_DISPLAYCONTROL | JHD1214_DISPLAYOFF | JHD1214_CURSOROFF
        | JHD1214_BLINKOFF);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    clear
// Description: Clear text from the LCD display
/////////////////////////////////////////////////////////////////////////////
function JHD1214::clear()
{
    _command(JHD1214_CLEARDISPLAY);
    setCursor(0, 0);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setCursor
// Description: Sets the cursor position on the display
// Arguments:   position - The position to move the cursor on the display.
/////////////////////////////////////////////////////////////////////////////
function JHD1214::setCursor(column, row)
{
    column = column % JHD1214_COLUMNS;
    row = row % JHD1214_ROWS;
    local command;
    if (row == 0)
        command = column | 0x80;
    else
        command = column | 0xC0;
    _row = row;
    _column = column;
    _command(command);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    write
// Description: Write string to the display at the current cursor position.
// Arguments:   s - The string to write
/////////////////////////////////////////////////////////////////////////////
function JHD1214::write(s)
{
    _i2c.address(_address);
    for (local i = 0; i < s.len(); i++) {
    delay(10);
    print(s[i] + "\n");
    _i2c.write8(0x40, s[i]);
    _column++;
    if (_column >= JHD1214_COLUMNS)
        setCursor(0, _row + 1);
}
}

/////////////////////////////////////////////////////////////////////////////
// Private Functions
/////////////////////////////////////////////////////////////////////////////
function JHD1214::_command(value)
{
    _i2c.address(_address);
    _i2c.write8(0x80, value);
    delay(1);
}