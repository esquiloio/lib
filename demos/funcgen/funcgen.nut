// Function Generator Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
require(["DAC", "math"]);

const VRANGE = 3.3;
const RESOLUTION = 4095;

// ERPC function to set the function generator operating
// parameters.
function set(params)
{
    // Select the wavefore closure
    switch (params.waveform) {
        case "sine":
        	params.waveform = sine;
        	break;
        case "rampup":
        	params.waveform = rampup;
        	break;
        case "rampdown":
        	params.waveform = rampdown;
        	break;
        case "square":
        	params.waveform = square;
        	break;
        case "triangle":
        	params.waveform = triangle;
        	break;
        case "pulse":
        	params.waveform = pulse;
        	break;
        case "dc":
        	params.waveform = dc;
        	break;
        case "noise":
        	params.waveform = noise;
        	break;
		default:
        	return false;
    }
    
    // Make sure the frequency is in range
    if (params.frequency < 100 || params.frequency > 10000)
        return false;

    // Check the amplitude and offset
    if (params.amplitude / 2 + params.offset > VRANGE ||
        params.amplitude / 2 + params.offset < 0)
        return false;

   	// Check the duty cycle
    if (params.duty > 99 || params.duty < 1)
        return false;
    
    waveform <- params.waveform;
    frequency <- params.frequency;
    amplitude <- params.amplitude;
    offset <- params.offset;
    duty <- params.duty;
    
    dac.frequency(frequency * buffer.len() / 2);
    generate();
    
    return true;
}

// Setup function
function setup()
{
	dac <- DAC(0);
    buffer <- blob(200);
}

// Generate the DAC samples from the current parameters
function generate()
{
    local len = buffer.len() / 2;
    buffer.seek(0);
    for (local i = 0; i < len; i++) {
        local volts = waveform(1.0 * i / len) * amplitude / 2 + offset;
        local data = volts * RESOLUTION / VRANGE;
        buffer.writen(data, 'w');
    }
    dac.stop();
	dac.loopblob(buffer);
}

// Sine waveform function
function sine(x)
{
    return sin(2 * PI * x);
}

// Ramp up waveform function
function rampup(x)
{
    return 2 * x - 1;
}

// Ramp down waveform function
function rampdown(x)
{
    return 1 - 2 * x;
}

// Square waveform function
function square(x)
{
    return x < 0.5 ? -1 : 1;
}

// Triangle waveform function
function triangle(x)
{
    if (x < 0.5)
        return (x * 4 - 1);
    else
        return (3 - 4 * x);
}

// Pulse waveform function
function pulse(x)
{
    return x < (1.0 * duty / 100) ? 1 : -1;
}

// DC waveform function
function dc(x)
{
    return 0;
}

// Noise waveform function
function noise(x)
{
    return 2 * (1.0 * rand() / RAND_MAX) - 1;
}

setup();
