// Sprinkler Controller Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

// Zone Class
//
// Manage a sprinkler zone controlled by a GPIO based on a time schedule
class Zone
{
    // Function:    Class Constructor
    // Description: Create
    // Arguments:   _name - string name to give the zone
    //              _gpio - GPIO object to activate the zone hardware
    constructor(_name, _gpio)
    {
        name = _name;
        gpio = _gpio;

        // Configure the GPIO and turn it off
        gpio.low();
        gpio.output();

        // Create a Zone table in the NV memory
        if (!("Zone" in nv))
            nv.Zone <- {};
        
        // Create a default table with this zone's name in the NV memory
        if (!(name in nv.Zone))
        {
            nv.Zone[name] <- {
	            start = 43200,
    	        duration = 300,
                days = [ false, false, false, false, false, false, false ],
        	    enable = false
            };
        }
       
        // Create timers with their callbacks bound to this class
        onTimer = Timer(onExpire.bindenv(this));
        offTimer = Timer(offExpire.bindenv(this));
       
        // Schedule the zone
        setOff();
    }
    
    // Function:    offExpire
    // Description: Called when off timer expires
    function offExpire()
    {
        setOff();
    }
    
    // Function:    onExpire
    // Description: Called when on timer expires
    function onExpire()
    {
        setOn(nv.Zone[name].duration);
    }

    // Function:    setOn
    // Description: Immediately turn on the zone for a certain duration
    // Arguments:   duration - time in seconds to leave zone on for
    function setOn(duration)
    {
        print(name + " on\n");
        
        // Stop all timers and turn the zone on
        onTimer.stop();
        offTimer.stop();
        gpio.high();
       
        // Set a timer for the duration
        print(name + " off timer scheduled for " + duration + " seconds\n");
        offTimer.start(duration * 1000);
    }
    
    // Function:    setOff
    // Description: Immediately turn zone off and schedule the next on time
    function setOff()
    {
        const SECS_PER_DAY = 86400;

        print(name + " off\n");
       
        // Stop all timers and turn the zone off
        onTimer.stop();
        offTimer.stop();
        gpio.low();

        // Only schedule if the zone is enabled
        if (nv.Zone[name].enable)
        {
            local now = date();
            local secs = SECS_PER_DAY * now.wday + now.hour * 3600 + now.min * 60 + now.sec;
            local start = 0;
           
            // Iterate through the days in the schedule to find the next on time
            for (local day = 0; day < 7; day++)
            {
                // Only enabled days apply
                if (nv.Zone[name].days[day])
                {
      	            local daystart = SECS_PER_DAY * day + nv.Zone[name].start;

                    // If the start time is later than now, then we found the next on time
                    if (secs < daystart)
                    {
                        start = daystart;
                        break;
                    }
                    // Else if this is the first day, then save the start time in case
                    // no other day is enabled
                    else if (start == 0)
                    {
                        start = daystart;
                    }
                }
            }
           
            // We found an enabled day
            if (start != 0)
            {
                // Calculate how long until the zone should turn on
                local expire = start - secs;

                // Handle weekly wrap-around
                if (expire < 0)
                    expire += 7 * SECS_PER_DAY;

                // Start the on timer
                print(name + " on timer scheduled for " + expire + " seconds\n");
                onTimer.start(expire * 1000);
            }
        }
    }
    
    // Function:    getIsOn
    // Description: Tell if the zone is currently on
    // Return:      true if zone is on and false if not
    function getIsOn()
    {
        return offTimer.running();
    }
    
    // Function:    getName
    // Description: Get the zone name
    // Return:      Zone name string
    function getName()
    {
        return name;
    }
    
    // Function:    getSchedule
    // Description: Get the schedule parameters
    // Return:      Table of schedule parameters
    function getSchedule()
    {
        return {
            start = nv.Zone[name].start,
            duration = nv.Zone[name].duration,
            days = nv.Zone[name].days,
            enable = nv.Zone[name].enable,
        };
    }

    // Function:    setSchedule
    // Description: set the schedule parameters and save in non-volatile memory
    // Arguments:   start - start time in seconds from midnight (0:00)
    //              duration - how long to run the zone in seconds
    //              days - bool array of days to run zone (0 - Sunday)
    //              enable - true if zone is enabled or false if not
    function setSchedule(start, duration, days, enable)
    {
        // Save the schedule in the NV memory
        nv.Zone[name].start <- start;
        nv.Zone[name].duration <- duration;
        nv.Zone[name].days <- days;
        nv.Zone[name].enable <- enable;

        // Save the NV memory
        ::nvsave();
       
        // Reschedule the zone
        setOff();
    }
   
    // Class members
    onTimer = null;
    offTimer = null;
    name = "";
    gpio = null;
}

//
// Web interface ERPC functions
//

// Function:    getZones
// Description: retrieve all of the zones
// Returns:     array with one table per zone
//                name: zone name string
//                schedule: table of schedule parameters
//                  start: zone start time in seconds since 0:00
//                  duration: zone run time in seconds
//                  days: array of bools for days to run zone (0 - Sunday)
//                  enable: bool of zone enabled
function getZones()
{
    local result = [];
    
    for (local i = 0; i < zoneList.len(); i++)
    {
        result.append({
            name = zoneList[i].getName(),
            schedule = zoneList[i].getSchedule()
        });
    }
    
    return result;
}

// Function:    getState
// Description: retrieve the controller state including the time and on zones
// Returns:     table of results
//                date: current time
//                onZones: array of zone indicies that are on
function getState()
{
    local result = {};
    
    result.date <- date();
    result.onZones <- [];
    
    for (local i = 0; i < zoneList.len(); i++)
    {
        if (zoneList[i].getIsOn())
        	result.onZones.append(i);
    }
    
    return result;
}

// Function:    setZoneSchedule   
// Description: set the schedule for a zone
// Arguments:   table of parameters
//                index: numerical index of zone from getZones
//                schedule: table of schedule parameters
//                  start: zone start time in seconds since 0:00
//                  duration: zone run time in seconds
//                  days: array of bools for days to run zone (0 - Sunday)
//                  enable: bool of zone enabled
// Returns:     true
function setZoneSchedule(params)
{
    local zone = zoneList[params.index];
    zone.setSchedule(params.start, params.duration, params.days, params.enable);
    return true;
}

// Function:    setZoneOn
// Description: immediately turn zone on
// Arguments:   table of parameters
//                index: numerical index of zone from getZones
//                duration: zone run time in seconds
// Return:      true
function setZoneOn(params)
{
    local zone = zoneList[params.index];
    zone.setOn(params.duration);
    return true;
}

// Function:    setZoneOn
// Description: immediately turn zone off
// Arguments:   table of parameters
//                index: numerical index of zone from getZones
// Return:      true
function setZoneOff(params)
{
    local zone = zoneList[params.index];
    zone.setOff();
    return true;
}

//
// Initalize sprinkler zones
//
zoneList <- [
    Zone("Front Yard",  GPIO(4)),
    Zone("Side Yards",  GPIO(5)),
    Zone("Back Yard",   GPIO(6)),
    Zone("Flower Beds", GPIO(7)),
];

