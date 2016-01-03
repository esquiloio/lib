// Rotary Angle Sensor Demo
//
// Ported from:
//   https://github.com/Seeed-Studio/Sketchbook_Starter_Kit_V2.0
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

// Controls an LED's brightness from a rotary angle control and prints the value
// of the potentiometer to the console pane at the bottom of the IDE.
//
// Connect the Grove Rotary Angle Sensor to the socket marked A0
// Connect the Grove LED Socket module to the socket marked D3
// Set the Grove Base Shield VCC switch to 3.3V

require(["ADC", "PWM", "math", "string"]);

// Defines the ADC (analog-to-digital converter) to which the rotary
// angle sensor (potentiometer) is connected
const ADC_POTENTIOMETER         = 0;
const ADC_POTENTIOMETER_CHANNEL = 0;

potentiometer <- ADC(ADC_POTENTIOMETER);

// LED brightness control
const PWM_LED         = 0;
const PWM_LED_CHANNEL = 1;

// Configure the LED's pin for output
ledPwm <- PWM(PWM_LED);
ledPwm.on(PWM_LED_CHANNEL);


brightness <- null;

// ERPC to fetch current brightness
function getBrightness()
{
    return brightness;
}

while(true) {
    // Read the value of the sensor
    local value = potentiometer.readv(ADC_POTENTIOMETER_CHANNEL);
    // Calculate the position as a percentage of the full range
    local percent = floor(value * 100.0 / 3.3);

    if (percent != brightness) {
        // Print the value to the console, if it has changed
    	print(format("%1.2fV (%d%%)\n", value, percent));
    }

    brightness = percent;

    ledPwm.duty_cycle(PWM_LED_CHANNEL, brightness);

    delay(100);
}