// Gas Meter Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

// Function:    shiftData
// Description: Shift the values in a data series
// Parameters:  array - array reference to the data series
//              now - the current index for the data series
// Return:      none
function shiftData(array, now)
{
    local delta = now - array[0];
    
    // Nothing to do here
    if (delta <= 0)
        return;
    
    print("shifting by " + delta + "\n");
    
    // Shift values down by the delta
    for (local i = array.len() - 1; i > delta; i--)
        array[i] = array[i - delta];
        
    // Zero values that were shifted
    for (local i = 1; i <= delta && i < array.len(); i++)
        array[i] = 0;
    
    array[0] = now;
}

// Function:    getData
// Description: Function to call via ERPC to collect our data series
// Parameters:  none
// Return:      A table of arrays containing the three data series
function getData()
{
    return {
        hourly = nv.gas.hourly,
        daily = nv.gas.daily,
        monthly = nv.gas.monthly
    };
}

function main()
{
    // Gas meter pulse input GPIO
    local pulse = GPIO(7);

    // Status LED on Esquilo board
    local status = GPIO(46);
    
    // Create gas table in the NV memory if not there
    if (!("gas" in nv)) {
        nv.gas <- {
            hourly = [],
            daily = [],
            monthly = []
        };
        
	    // Add one for the time at index 0
        nv.gas.hourly.resize(25, 0);
        nv.gas.daily.resize(32, 0);
        nv.gas.monthly.resize(13, 0);
    }

    // Initialize the gas meter pulse input
    pulse.input();
    pulse.pullup(true);
    local level = pulse.read();
    
    // Initialize the status LED
    status.output();
    status.write(level);
    
    local last = time();
    
    while (true) {
        // Wait for a high pulse
        while (!pulse.ishigh())
            delay(10);
        
        print("pulse!\n");

        // Match the LED to the pulse level
        status.write(level);

        // Shift the data by the current time
        local now = time();
        shiftData(nv.gas.hourly, now / 3600);
        shiftData(nv.gas.daily, now / 86400);
        now = date(now);
        shiftData(nv.gas.monthly, (now.year - 1970) * 12 + now.month);

        // Increment the counters
        nv.gas.monthly[1]++;
        nv.gas.daily[1]++;
        nv.gas.hourly[1]++;

        // Save the data periodically in case of power failure
        if (time() - last > 600) {
            print("save\n");
            last = time();
            nvsave();
        }
        
        // Wait for the low pulse
        while (!pulse.islow())
            delay(10);
    }
}

main();
