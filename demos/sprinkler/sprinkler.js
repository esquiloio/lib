// Sprinkler Controller Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
var zoneList = [];
var zoneSelected;
var nowDuration = 300;
var daysOfWeek = [ 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' ];

function initControls()
{
    //
    // Start/stop controls
    //

    // Stop button
    $('#stopButton').click(function() {
        var params = {
            index: zoneSelected.index,
        };
        erpc("setZoneOff", params, function(result) {
            if (result) {
                getState();
            }
        });
    });

    // Start button
    $('#startButton').click(function() {
        var params = {
            index: zoneSelected.index,
            duration: nowDuration,
        };
        erpc("setZoneOn", params, function(result) {
            if (result) {
                getState();
            }
        });
    });

    // Start duration time picker
    $('#nowDurationPicker').timepicker({
        minuteStep: 1,
        showMeridian: false,
        defaultTime: secsToHourMin(nowDuration)
    });

    $('#nowDurationPicker').timepicker().on('changeTime.timepicker', function(e) {
        nowDuration = e.time.hours * 3600 + e.time.minutes * 60;
        scheduleDirty();
    });

    //
    // Schedule controls
    //

    // Schedule start time picker
    $('#scheduleStartPicker').timepicker({
        minuteStep: 1,
        showMeridian: false
    });

    // Schedule duration time picker
    $('#scheduleDurationPicker').timepicker({
        minuteStep: 1,
        showMeridian: false
    });

    // Days of week checkboxes
    for (var i = 0; i < 7; i++) {
        $('#checkbox' + i).click(function(i) {
            return function() {
                zoneSelected.schedule.days[i] = $(this).is(':checked');
                scheduleDirty();
            }
        }(i));
    }

    // Schedule enable checkbox
    $('#checkboxEnable').click(function() {
        zoneSelected.schedule.enable = $(this).is(':checked');
        scheduleDirty();
    });

    // Save button
    $('#saveButton').click(function() {
        var schedule = zoneSelected.schedule;
        var params = {
            index: zoneSelected.index,
            start: schedule.start,
            duration: schedule.duration,
            days: schedule.days,
            enable: schedule.enable
        };

        // Call ERPC setZoneSchedule() to set the schedule
        erpc("setZoneSchedule", params, function(result) {
            if (result) {
                zoneSelected.dirty = false;
                $('#saveButton').addClass('disabled');
            }
        });
    });

}

function initZones()
{
    // Call ERPC getZones() to retrieve all of the zones
    erpc("getZones", null, function(result) {
        if (result) {
            zoneList = result;

            // For each zone, insert it in the zone drop down list and save it
            // in the zone list
            for (var i = 0; i < zoneList.length; i++) {
                var zoneId = i;
                $('#zoneList').append('<li><a href="#" id="zone' + i + '">' +
                                      zoneList[i].name + '</a></li>');
                $('#zone' + i).click(function(i) {
                    return function(e) {
                        selectZone(i);
                        e.preventDefault();
                    }
                }(i));
                zoneList[i].index = i;
                zoneList[i].isOn = false;
                zoneList[i].dirty = false;
            }

            // Select the first zone
            if (zoneList.length > 0) {
                selectZone(0);
            }
            
            // Poll the state periodically
            getState();
            window.setInterval(getState, 5000);
        }
    });
}

// Mark the schedule as dirty when it changes
function scheduleDirty()
{
    zoneSelected.dirty = true;
    $('#saveButton').removeClass('disabled');
}

// Retrieve the controller state from the Esquilo
function getState()
{
    // Call ERPC getState() to get the state
    erpc("getState", null, function(result) {
        if (result) {
            var onZones = "";
            
            // Show the active zone names in a list
            for (var i = 0; i < zoneList.length; i++) {
                zoneList[i].isOn = false;
            }
            for (var i = 0; i < result.onZones.length; i++) {
                var zone = zoneList[result.onZones[i]];
                zone.isOn = true;
                onZones += zone.name + ",";
            }
			onZones = onZones.slice(0, -1);
            if (onZones == "")
                onZones = "None";
            
            $('#onZones').text(onZones);

            // Update the start/stop buttons based on zone state
            if (zoneSelected.isOn) {
                $('#startButton').addClass('disabled');
                $('#stopButton').removeClass('disabled');
            }
            else {
                $('#startButton').removeClass('disabled');
                $('#stopButton').addClass('disabled');
            }

            // Show the current time and day of week
            $('#time').text(result.date.hour + ":" +
                            (result.date.min < 10 ? '0' : '') +
                            result.date.min);
            $('#day').text(daysOfWeek[result.date.wday]);
        }
    });
}

// Convert seconds to an HOUR:MIN format string
function secsToHourMin(secs)
{
	return secs / 3600 + ':' + secs / 60 % 60;
}

// Called when start time picker updates
function changeStart(e)
{
	var start = e.time.hours * 3600 + e.time.minutes * 60;
    
    // Only handle changes
    if (start != zoneSelected.schedule.start)
    {
        zoneSelected.schedule.start = start;
        scheduleDirty();
    }
}

// Called when duration time picker updates
function changeDuration(e)
{
    var duration = e.time.hours * 3600 + e.time.minutes * 60;
    
    // Only handle changes
    if (duration != zoneSelected.schedule.duration)
    {
    	zoneSelected.schedule.duration = duration;
    	scheduleDirty();
    }
}

// Select the current zone by its index in the zone list
function selectZone(index)
{
  	zoneSelected = zoneList[index];
   
    // Update the start/stop buttons based on zone on state
    $('#zoneSelect').text(zoneSelected.name);
    if (zoneSelected.isOn) {
        $('#startButton').addClass('disabled');
        $('#stopButton').removeClass('disabled');
    }
    else {
        $('#startButton').removeClass('disabled');
        $('#stopButton').addClass('disabled');
    }
   
    // Update the schedule start time picker
    $('#scheduleStartPicker').timepicker().off('changeTime.timepicker');
    $('#scheduleStartPicker').timepicker('setTime', secsToHourMin(zoneSelected.schedule.start));
    $('#scheduleStartPicker').timepicker().on('changeTime.timepicker', changeStart);
    
    // Update the schedule duration time picker
    $('#scheduleDurationPicker').timepicker().off('changeTime.timepicker');
    $('#scheduleDurationPicker').timepicker('setTime', secsToHourMin(zoneSelected.schedule.duration));
    $('#scheduleDurationPicker').timepicker().on('changeTime.timepicker', changeDuration);
   
    // Update the days of the week
    var days = zoneSelected.schedule.days;
    for (var i = 0; i < days.length; i++) {
        $('#checkbox' + i).prop('checked', days[i]);
    }
    
    // Update the schedule enable checkbox
    $('#checkboxEnable').prop('checked', zoneSelected.schedule.enable);
   
    // Update the save button
    if (zoneSelected.dirty)
    	$('#saveButton').removeClass('disabled');
    else
    	$('#saveButton').addClass('disabled');
}

// Initialize the controls
initControls();

// Initialize the zones
initZones();

