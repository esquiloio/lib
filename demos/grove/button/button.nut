// Grove Button Demo
//
// Ported from:
//   https://github.com/Seeed-Studio/Sketchbook_Starter_Kit_V2.0
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

// Uses a Grove Button to control a Grove LED.
//  - Connect the Grove Button to socket D7
//  - Connect the Grove LED to socket D3

// Import the GPIO library
require("GPIO");

// Defines the pins to which the button and LED are connected
const PIN_BUTTON = 7;
const PIN_LED    = 3;

// Configure the button pin for input
button <- GPIO(PIN_BUTTON);
button.input();

// Configure the LED pin for output
led <- GPIO(PIN_LED);
led.output();

// Track the state of the web app virtual button
isVirtualButtonOn <- false;

// ERPC method to set the virtual button from the web app
function setIsVirtualButtonOn(value)
{
  isVirtualButtonOn = value;
}

// ERPC method to get the button state
function getIsGroveButtonOn()
{
  return button.ishigh();
}

while (true) {
  // If either of the buttons is pressed turn the LED on
  if ((button.ishigh() && !isVirtualButtonOn) ||
      (button.islow() && isVirtualButtonOn)) {
    led.high();
  } else {
    led.low();
  }

  // Sleep for 50ms to give the idle loop time to process the IDE, etc.  
  delay(50);
}