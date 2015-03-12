///////////////////////////////////////////////////////////////////////////////
// Welcome to the Esquilo boot nut!
//
// The Esquilo boot nut is a squirrel nut that your Esquilo can execute every
// time it boots.  It is stored in a special area of flash inside of the ARM
// processor so it is available even if there is no micro SD card.  You can
// change the boot nut setting either from the Esquilo IDE under the system
// menu or with the "sq boot <true|false> command from an EOS shell.
//
// What you do with the boot nut is up to you.  You can write your entire
// application in the boot.nut or you can use it as a springboard to a nut
// stored elsewhere.
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Run a nut on the micro SD card
///////////////////////////////////////////////////////////////////////////////
// dofile("sd:/blinky.nut");

///////////////////////////////////////////////////////////////////////////////
// Run your own application
///////////////////////////////////////////////////////////////////////////////

// The status LED is on pin 46 so create a GPIO object on that pin
led <- GPIO(46);

// Configure the GPIO as a digital output
led.output();

// Function to toggle the LED state
function blinky()
{
    if (led.ishigh())
    	led.low();
  	else
    	led.high();
}

// Blink the LED every half second
while (true)
{
    blinky();
    delay(500);
}

///////////////////////////////////////////////////////////////////////////////
// Run an Arduino-style application
///////////////////////////////////////////////////////////////////////////////

/*
// Set the LED pin number
ledPin <- LED_BUILTIN;

// Configure the LED as an output
function setup()
{
    pinMode(ledPin, OUTPUT);
}

// Loop blinking the LED every half second
function loop()
{
    digitalWrite(ledPin, HIGH);
    delay(500);
    digitalWrite(ledPin, LOW);
    delay(500);
}

// Run the Arduino loop
run();
*/

