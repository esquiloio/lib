/////////////////////////////////////////////////////////////////////////////
// DHT11 family relative humidity and temperature sensor class
// (Works with all 40 bit, 1 wire sensors such as DHT11, DHT22, RHT03, etc.)
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
// Example usage:
//
// sensor <- DHT11(/*Pin*/ 6, /*PWM*/ 1, /*Channel*/ 0, /*Divider*/ 256);
//
// while(true) {
//    local values = sensor.read();
//    print(format("humidity: %f%% temperature: %fC\n", values[0], values[1]);
//    delay(2000);
// }
//
class DHT11
{
    pin = 0;
    chan = 0;
    cap = null;
    divider = 0;
}

const DHT11_TIMEOUT = 100000;  // microseconds
const DHT11_WIDTH   = 100;     // microseconds
const DHT11_BITS    = 41;

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a DHT11 sensor.  Must be on a PWM pin.
// Arguments:   _pin     - The pin number the sensor is connected to
//              _pwm     - The PWM number of the pin
//              _channel - The PWM channel of the pin
//              _divider - The divider for the data (DTH11: 256, DHT22: 10)
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function DHT11::constructor(_pin, _pwm, _chan, _divider)
{
    pin = _pin;

    cap = Capture(_pwm)
    cap.edge(_chan, CAPTURE_EDGE_FALLING);
    cap.arm(_chan, CAPTURE_EDGE_FALLING);

    chan = _chan;

    divider = _divider;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    read
// Description: Read the humidity and ambient temperature from the sensor
// Arguments:   None
// Return:      Array with relative humidity in percent and
//              temperature in Celsius
/////////////////////////////////////////////////////////////////////////////
function DHT11::read()
{
    // Generate the start pulse with a GPIO
    local gpio = GPIO(pin);
    gpio.low();
    gpio.output();
	delay(20);

    // Read the output pulses after the start pulse
    local bits = cap.readarray(chan, DHT11_BITS, DHT11_TIMEOUT);
    
    // Make sure we got all of the bits
    if (bits.len() != DHT11_BITS)
        throw("unable to read sensor");
    
    // Decode the bits into bytes
    local bytes = array(5, 0);
    for (local bitCount = 1; bitCount < DHT11_BITS; bitCount++) {
        local bitNum = (bitCount - 1) % 8;
        local byteNum = (bitCount - 1) / 8;
        if (bits[bitCount] - bits[bitCount - 1] >= DHT11_WIDTH)
            bytes[byteNum] = bytes[byteNum] | (0x80 >> bitNum);
    }
    
    // Verify the checksum
    local checksum = bytes[0] + bytes[1] + bytes[2] + bytes[3];
	if ((checksum & 0xff) != bytes[4])
        throw("checksum mismatch");
    
    // Calculate humidity
    local humidity = bytes[0] << 8 | bytes[1];
    if (humidity & 0x8000)
        humidity = - (humidity & 0x7fff);
    humidity = humidity.tofloat() / divider;
        
    // Calculate temperature
    local temperature = bytes[2] << 8 | bytes[3];
    if (temperature & 0x8000)
        temperature = - (temperature & 0x7fff);
    temperature = temperature.tofloat() / divider;
        
    return [ humidity, temperature ];
}
