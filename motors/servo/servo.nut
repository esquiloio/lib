/////////////////////////////////////////////////////////////////////////////
// Generic servo class
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Example usage:
//
// /* Control a servo on PWM1 channel 0 (pin 6 on Esquilo) */
// pwm <- PWM(1)
// servo <- Servo(pwm, 6);
// 
// /* Set the servo to 20 degrees */
// servo.position(20);
//
// /* Set the servo to 83 degrees */
// servo.position(83);
//
class Servo
{
    // A typical servo needs pulses every 50Hz
    frequency = 50;
    
    // ...and pulse widths between 1ms and 2ms
    min_pulse = 1.0;
    max_pulse = 2.0;
    
    // ...that cause a movement between 0 and 90 degrees.
    min_range = 0;
    max_range = 90;
    
	// The PWM instance and channel to send the pulses over	   
    pwm = null;
    channel = 0;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a Servo class instance
// Arguments:   _pwm - An instance of PWM class
//              _channel - The channel number of the PWM instance
/////////////////////////////////////////////////////////////////////////////
function Servo::constructor(_pwm, _channel)
{
    if (!(_pwm instanceof PWM))
        throw("not a PWM instance");
    if (_channel < 0 || _channel >= _pwm.channels())
        throw("invalid PWM channel");

    pwm = _pwm;
    channel = _channel;
    
    pwm.frequency(frequency);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setPulses
// Description: Set the pulse widths for the servo.
// Arguments:   _min_pulse - Minimum pulse width in milliseconds
//              _max_pulse - Maximum pulse width in milliseconds
/////////////////////////////////////////////////////////////////////////////
function Servo::setPulses(_min_pulse, _max_pulse)
{
	if (_min_pulse >= _max_pulse)
        throw("minimum pulse width exceeded maximum");
    if (_min_pulse < 0 || _max_pulse > 1000.0 / frequency)
        throw("invalid pulse width");
    
    min_pulse = _min_pulse;
    max_pulse = _max_pulse;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setRange
// Description: Set the positioning range accepted for the servo.  The
//              minimum range will set the minimum duty cycle and the 
//              maximum range will set the maximum duty cycle.
// Arguments:   _min_range - Minimum range
//              _max_range - Maximum range
/////////////////////////////////////////////////////////////////////////////
function Servo::setRange(_min_range, _max_range)
{
	if (_min_range >= _max_range)
        throw("minimum range exceeded maximum");
    
    min_range = _min_range;
    max_range = _max_range;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setFrequency
// Description: Set the frequency of the pulses sent to the servo.
// Arguments:   _frequency - Pulse frequency in hertz
/////////////////////////////////////////////////////////////////////////////
function Servo::setFrequency(_frequency)
{
    if (frequency < 0)
        throw("invalid frequency");
    
    frequency = _frequency;
    
    pwm.off(channel);
    pwm.frequency(_frequency);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    position
// Description: Sets the servo position.  The position must be within the
//              set range and is scaled linearly between.
// Arguments:   _position - The servo position
/////////////////////////////////////////////////////////////////////////////
function Servo::position(_position)
{
    local duty;
    
    if (_position < min_range || _position > max_range)
        throw("position out of range");
    
    local max_duty = max_pulse / 10.0 * frequency;
    local min_duty = min_pulse / 10.0 * frequency;
    
    duty = (_position - min_range) / (max_range - min_range) * (max_duty - min_duty) + min_duty;
    
    pwm.duty_cycle(channel, duty);
    pwm.on(channel);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    off
// Description: Stops sending pulses to the servo
// Arguments:   None
/////////////////////////////////////////////////////////////////////////////
function Servo::off()
{
    pwm.off(channel);
}

