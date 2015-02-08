// Remote LCD Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

// Serial commands - see product specs for more info:
// http://www.newhavendisplay.com/nhd0216k3zfsrgbfbwv3-p-5736.html
const LCD_CMD      = 0xfe;
const LCD_ON       = 0x41;
const LCD_OFF      = 0x42;
const LCD_CURSOR   = 0x45;
const LCD_CLEAR    = 0x51;
const LCD_CONTRAST = 0x52;

// TODO: placeholder
function PWM(pwm, pin)
{
    return pin;
}

// LCD Class
//
// Manages a Newhaven 16x2 serial RGB LCD module controlled with a UART bus and
// three PWM pins for the backlight.
class Lcd
{
    // Function:    Class Constructor
    // Description: Create
    // Arguments:   _uart - UART object the LCD is attached to
    //              pwm - number of PWM the LCD backlight pins are attached to
    //              redChannel - PWM channel of red backlight
    //              greenChannel - PWM channel of green backlight
    //              blueChannel - PWM channel of blue backlight
	constructor(_uart, pwm, redChannel, greenChannel, blueChannel)
    {
        // Configure UART for 8 bits, no parity, 1 stop bit, 9600 bps
        uart = _uart;
        uart.mode(UART.MODE_8N1);
        uart.speed(9600);

        // Initialize backlight PWM channels
        backlight.red.pwm   = PWM(pwm, redChannel);
        backlight.green.pwm = PWM(pwm, greenChannel);
        backlight.blue.pwm  = PWM(pwm, blueChannel);

        // Initialize LCD with a clear screen, a default contrast, and powered off
        clear();
        setContrast(30);
        off();
    }

    uart = null;
    _isOn = false;
    line = 0;
    column = 0;
    backlight = {
        red = {
            pwm   = null,
            level = 0
        },
            green = {
            pwm   = null,
            level = 0
        },
            blue = {
            pwm   = null,
            level = 0
        }
    }

    // Function:    on
    // Description: Turns the LCD display on. This will restore the backlight
    //              settings to what they were before the LCD was turned off.
    function on()
    {
        _isOn = true;
        uart.puts(LCD_CMD.tochar());
        uart.puts(LCD_ON.tochar());
        delay(1);
        _backlightOn();
    }

    // Function:    off
    // Description: Turns the LCD display off. This will save the backlight
    //              settings to restore when the LCD is turned back on.
    function off()
    {
        _isOn = false;
        uart.puts(LCD_CMD.tochar());
        uart.puts(LCD_OFF.tochar());
        delay(1);
        _backlightOff();
    }
    
    // Function:    isOn
    // Description: Tell if the LCD is on
    // Returns:     true
    function isOn() {
        return _isOn;
    }

    // Function:    clear
    // Description: Clear text from the LCD display
    function clear()
    {
        line = 0;
        column = 0;
        uart.puts(LCD_CMD.tochar());
        uart.puts(LCD_CLEAR.tochar());
        delay(10);
    }

    // Function:    setCursor
    // Description: Sets the cursor position on the the display
    // Arguments:   position - The position to move the cursor on the 2-line
    //                         display.
    //                           0x00 - 0x0f: line 1, column 1 - 16
    //                           0x40 - 0x4f: line 2, column 1 - 16
    function setCursor(position)
    {
        switch (position & 0xf0) {
        case 0x00:
            row = 0;
            break;
        case 0x40:
            row = 1;
            break;
        default:
            // Error
            return;
        }
        column = position & 0x0f;
        uart.puts(LCD_CMD.tochar());
        uart.puts(LCD_CURSOR.tochar());
        uart.puts(position.tochar());
        delay(1);
    }

    // Function:    setContrast
    // Description: Sets the display contrast
    // Arguments:   level - The contrast level to set the display to (0 - 50)
    function setContrast(level)
    {
        uart.puts(LCD_CMD.tochar());
        uart.puts(LCD_CONTRAST.tochar());
        uart.puts(level.tochar());
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
            if (line == 0 && (c == '\n' || column == 16)) {
                // Got to second line
                setCursor(0x40);
                line = 1;
                column = 0;
            }
            uart.puts(c);
            column++;
        }
    }

    // Function:    setBacklight
    // Description: Set the backlight color with values specified
    // Arguments:   red - Red level (0 - 255)
    //              green - Green level (0 - 255)
    //              blue - Blue level (0 - 255)
    function setBacklight(red, green, blue)
    {
        backlight.red.level   = red;
        backlight.green.level = green;
        backlight.blue.level  = blue;
        _setBacklightLevels(red, green, blue);
    }

    // ?
    function close()
    {
        //  uart.close();
    }

    // Private methods (prefixed with '-' by convention)

    function _backlightOff()
    {
        _setBacklightLevels(0, 0, 0);
    }

    function _backlightOn()
    {
        _setBacklightLevels(backlight.red.level, backlight.green.level, backlight.blue.level);
    }

    function _setBacklightLevels(red, green, blue)
    {
        // TODO: PWM
    }
}

//
// Web interface ERPC functions
//

// Function:    on
// Description: Turns LCD power on
// Returns:     true
function on() {
    lcd.on();
    return true;
}

// Function:    off
// Description: Turns LCD power off
// Returns:     true
function off() {
    lcd.off();
    return true;
}

// Function:    isOn
// Description: Tell if the LCD is on
// Returns:     true
function isOn() {
    return lcd.isOn();
}

// Function:    clear
// Description: Clears the LCD display
// Returns:     true
function clear() {
    lcd.clear();
    return true;
}

// Function:    setMessage
// Description: Write message to LCD
// Arguments:   table of parameters
//                message: message string to display
// Returns:     true
function setMessage(params) {
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
	lcd.setBacklight(params.red, params.green, params.blue);
}

// Initialize serial LCD
lcd<-Lcd(UART(4), 0, 2, 3, 4);