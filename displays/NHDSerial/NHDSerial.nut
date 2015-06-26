/////////////////////////////////////////////////////////////////////////////
// Newhaven Display serial LCD class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Example usage:
//
// lcd = NHDSerial(UART(1));
// lcd.on();
// lcd.setCursor(0,0);
// lcd.write("Hello World!");
//

// Command ID's
const NHD_CMD      	    = 0xfe;
const NHD_DISPLAY_ON    = 0x41;
const NHD_DISPLAY_OFF   = 0x42;
const NHD_SET_CURSOR   	= 0x45;
const NHD_UNDERLINE_ON  = 0x47;
const NHD_UNDERLINE_OFF = 0x48;
const NHD_CURSOR_LEFT   = 0x49;
const NHD_CURSOR_RIGHT  = 0x4a;
const NHD_BLINK_ON      = 0x4b;
const NHD_BLINK_OFF     = 0x4c;
const NHD_BACKSPACE     = 0x4e;
const NHD_CLEAR         = 0x51;
const NHD_CONTRAST 	    = 0x52;
const NHD_BRIGHTNESS    = 0x53;

class NHDSerial
{
    uart = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    Class Constructor
// Description: Create
// Arguments:   _uart - UART object to control the display
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::constructor(_uart)
{
    // Configure UART for 8 bits, no parity, 1 stop bit, 9600 bps
    uart = _uart;
    uart.mode(UART_MODE_8N1);
    uart.speed(9600);
    
    // Initialize LCD with a clear screen, a default contrast, and off
    clear();
    setContrast(30);
    off();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    on
// Description: Turns display on
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::on()
{
    cmd(NHD_DISPLAY_ON);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    off
// Description: Turns display off
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::off()
{
    cmd(NHD_DISPLAY_OFF);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    clear
// Description: Clear text from the LCD display
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::clear()
{
    cmd(NHD_CLEAR);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setCursor
// Description: Sets the cursor position on the display
// Arguments:   position - The position to move the cursor on the display.
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::setCursor(column, row)
{
    local position;
    
    switch (row) {
        case 0:
        	position = 0x00;
        	break;
        case 1:
        	position = 0x40;
        	break;
        case 2:
        	position = 0x14;
        	break;
        case 3:
        	position = 0x54;
        	break;
        default:
        	return;
    }

    cmdParam(NHD_SET_CURSOR, position + column);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    underlineCursor
// Description: Turn the underline cursor on and off
// Arguments:   state - true for cursor on and false for cursor off
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::underlineCursor(state)
{
  	if (state)
    	cmd(NHD_UNDERLINE_ON);
    else
    	cmd(NHD_UNDERLINE_OFF);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    blinkCursor
// Description: Turn the blink cursor on and off
// Arguments:   state - true for cursor on and false for cursor off
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::blinkCursor(state)
{
  	if (state)
    	cmd(NHD_BLINK_ON);
    else
    	cmd(NHD_BLINK_OFF);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    cursorLeft
// Description: Move the cursor left one position
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::cursorLeft()
{
    cmd(NHD_CURSOR_LEFT);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    cursorRight
// Description: Move the cursor left one position
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::cursorRight()
{
    cmd(NHD_CURSOR_RIGHT);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    cursorRight
// Description: Move the cursor back one position erasing the character
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::backspace()
{
    cmd(NHD_BACKSPACE);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setContrast
// Description: Sets the display contrast
// Arguments:   level - The contrast level to set the display to (0 - 50)
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::setContrast(level)
{
    cmdParam(NHD_CONTRAST, level);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setBrightness
// Description: Sets the display brightness
// Arguments:   level - The contrast level to set the display to (0 - 8)
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::setBrightness(level)
{
    cmdParam(NHD_BRIGHTNESS, level);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    write
// Description: Write string to the display at the current cursor position.
// Arguments:   s - The string to write
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::write(s)
{
    uart.writestr(s);
}

/////////////////////////////////////////////////////////////////////////////
// Privte Functions
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// Function:    cmd
// Description: Send a command to the LCD
// Arguments:	id - Command ID
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::cmd(id)
{
    uart.write(NHD_CMD);
    uart.write(id);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    cmdParam
// Description: Send a command with a parameter to the LCD
// Arguments:	id - Command ID
/////////////////////////////////////////////////////////////////////////////
function NHDSerial::cmdParam(id, param)
{
    uart.write(NHD_CMD);
    uart.write(id);
    uart.write(param);
}
