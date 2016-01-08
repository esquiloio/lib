// Grove Temperature Sensor Demo
//
// Ported from:
//   https://github.com/Seeed-Studio/Sketchbook_Starter_Kit_V2.0
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

// Displays the temperature read from a Grove Temperature Sensor
//
// Connect the Grove Temperature Sensor module to the socket marked A0

require(["ADC", "math"]);

// Defines the ADC (analog-to-digital converter) to which the temp sensor is connected
const ADC_TEMPERATURE         = 0;
const ADC_TEMPERATURE_CHANNEL = 0;

const B  = 4275;      // B value of the thermistor
const R0 = 100000.0;  // Ohm value of resistor R0

temperatureAdc <- ADC(ADC_TEMPERATURE);

temperature <- 0;

// ERPC to fetch current temperature
function getTemperature()
{
    return temperature;
}

while(true) {
    // Read the value of the sensor
    local value = temperatureAdc.readv(ADC_TEMPERATURE_CHANNEL);

    local R = 3.3/(value)-1.0;
    R = 100000.0*R;
    local C = 1.0/(log(R/R0)/B+1/298.15)-273.15;
    temperature = C * 1.8 + 32.0;

    delay(300);
}