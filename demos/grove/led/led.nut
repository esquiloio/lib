// Grove LED Demo
//
// Ported from:
//   https://github.com/Seeed-Studio/Sketchbook_Starter_Kit_V2.0
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
require("PWM");

// Pulses the Grove - LED with a "breathing" effect
// Connect the Grove - LED to the socket marked D3 (PWM0:Channel1)
const PWM_LED         = 0;
const PWM_LED_CHANNEL = 1;

// Define the delay for the "breathing" effect; change this
// to a smaller value for a faster effect, larger for slower.
breathDelay <- 5;
brightness <- 0;

// Configure the LED's pin for output
ledPwm <- PWM(PWM_LED);
ledPwm.on(PWM_LED_CHANNEL);

// ERPC method to set the virtual button from the web app
function setBreathDelay(value)
{
  print("breath delay: " + value + "\n"); 
  breathDelay = value;
}

// ERPC to fetch current brightness
function getBrightness()
{
    return brightness;
}

while (true) {
    for(brightness = 0; brightness < 100; brightness++) {
        ledPwm.duty_cycle(PWM_LED_CHANNEL, brightness);
        delay(breathDelay);
    }
    delay(100);

    for(brightness = 100; brightness >= 0; brightness--) {
        ledPwm.duty_cycle(PWM_LED_CHANNEL, brightness);
        delay(breathDelay);
    }
    delay(500);
}