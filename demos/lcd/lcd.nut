// Remote LCD Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

dofile("sd:/lib/displays/NHDSerial/NHDSerial.nut");
dofile("sd:/lib/displays/RGBLED/RGBLED.nut");

// LCD Class
//
// Manages a Newhaven 16x2 serial RGB LCD module controlled with a UART and
// three PWM pins for the backlight.
class Lcd
{
    // Function:    Class Constructor
    // Description: Create
    // Arguments:   uart - UART object to control the display
    //              pwm - PWM object to control the backlight
    //              redChannel - PWM channel of red backlight
    //              greenChannel - PWM channel of green backlight
    //              blueChannel - PWM channel of blue backlight
	constructor(columns, rows, uart, pwm, redChannel, greenChannel, blueChannel)
    {
	    _maxColumn = columns - 1;
	    _maxRow = rows - 1;
        
        _nhd = NHDSerial(uart);
        _led = RGBLED(pwm, redChannel, greenChannel, blueChannel);
    }

    _nhd = null;
    _led = null;
    _onState = false;
    _row = 0;
    _column = 0;
    _maxColumn = 0;
    _maxRow = 0;

    // Function:    on
    // Description: Turns display on
    function on()
    {
        _onState = true;
        _nhd.on();
        _led.on();
        delay(1);
    }

    // Function:    off
    // Description: Turns display off
    function off()
    {
        _onState = false;
        _nhd.off();
        _led.off();
        delay(1);
    }
    
    // Function:    isOn
    // Description: Query display state
    // Returns:     true
    function isOn()
    {
        return _onState;
    }

    // Function:    clear
    // Description: Clear text from the LCD display
    function clear()
    {
        _row = 0;
        _column = 0;
        _nhd.clear();
        delay(10);
    }

    // Function:    setCursor
    // Description: Sets the cursor position on the display
    // Arguments:   position - The position to move the cursor on the 2-row
    //                         display.
    //                           0x00 - 0x0f: row 1, column 1 - 16
    //                           0x40 - 0x4f: row 2, column 1 - 16
    function setCursor(column, row)
    {
        if (column < 0 || column > _maxColumn || row < 0 || row > _maxRow)
            throw("invalid cursor position");
        
        _column = column;
        _row = row;
        lcd.setCursor(column, row);
        delay(1);
    }

    // Function:    setContrast
    // Description: Sets the display contrast
    // Arguments:   level - The contrast level to set the display to (0 - 50)
    function setContrast(level)
    {
        if (level < 0 || level > 50)
            throw("invalid contrast");

        _lcd.setContrast(level);
        delay(1);
    }

    // Function:    print
    // Description: Prints a string to the display, starting at the current
    //              cursor position.
    // Arguments:   s - The string to print
    function print(s)
    {
        for (local i = 0; i < s.len(); i++) {
            local c = s[i].tochar();
            if ((c == "\n" || _column > _maxColumn) && _row < _maxRow ) {
                _row++;
                _column = 0;
                _nhd.setCursor(_column, _row);
            }
            if (c != "\n") {
            	_nhd.write(c);
            	_column++;
            }
        }
    }

    // Function:    setBacklight
    // Description: Set the backlight color with values specified
    // Arguments:   red - Red level (0 - 255)
    //              green - Green level (0 - 255)
    //              blue - Blue level (0 - 255)
    function setBacklight(red, green, blue)
    {
        _led.red(red);
        _led.green(green);
        _led.blue(blue);
    }
}

//
// Web interface ERPC functions
//

// Function:    on
// Description: Turns display on
// Returns:     true
function on() 
{
    lcd.on();
    return true;
}

// Function:    off
// Description: Turns display off
// Returns:     true
function off() 
{
    lcd.off();
    return true;
}

// Function:    isOn
// Description: Query display state
// Returns:     
function isOn() 
{
    return lcd.isOn();
}

// Function:    clear
// Description: Clears the LCD display
// Returns:     true
function clear() 
{
    lcd.clear();
    return true;
}

// Function:    setMessage
// Description: Write message to LCD
// Arguments:   table of parameters
//                message: message string to display
// Returns:     true
function setMessage(params) 
{
    lcd.clear();
    lcd.print(params.message);
    return true;
}

// Function:    setBacklight
// Description: Set the backlight color with values specified
// Arguments:   table of parameters
//                red: red backlight level (0 - 255)
//                green: green backlight level (0 - 255)
//                blue: blue backlight level (0 - 255)
// Returns:     true
function setBacklight(params) {
	lcd.setBacklight(params.red.tointeger(), params.green.tointeger(), params.blue.tointeger());
}

// Initialize the 16x2 serial LCD using UART0 and PWM0 channels 0 - 2
lcd<-Lcd(16, 2 UART(0), PWM(0), 0, 1, 2);
lcd.print("Simple IoT\nDevelopment");
lcd.setBacklight(0, 153, 239);
lcd.on();
