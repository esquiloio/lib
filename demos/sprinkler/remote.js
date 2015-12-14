// Sprinkler Controller Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
var duration = 5;
var startClick;
var zoneSelect;

function error(text)
{
    $('#errorText').text(text);
    $('#errorModal').modal();
}

function startProgram(program)
{
    erpc("startProgram", [program], null, function() {
        error("Program start failed");
    });
}

function startZone(zone)
{
    erpc("startZone", [zone, duration], null, function() {
        error("Zone start failed");
    });
}

function initControls()
{
    // Stop button
    $('#stopButton').click(function() {
        erpc("stop", null, null, function() {
            error("Zone stop failed");
        });
    });

    // Start button
    $('#startButton').click(function() {
        if (startClick) {
            startClick();
        }
        else {
            error("Select a zone or program");
        }
    });

    // Duration time picker
    $('#durationPicker').timepicker({
        minuteStep: 1,
        showMeridian: false,
        defaultTime: minsToHourMin(duration)
    });

    $('#durationPicker').timepicker().on('changeTime.timepicker', function(e) {
        duration = e.time.hours * 60 + e.time.minutes;
    });
}

function initPrograms()
{
    // Call ERPC getPrograms() to retrieve all of the programs
    erpc("getPrograms", null, function(result) {
        if (result) {
            // For each program, insert it in the zone drop down list
            for (var i = 0; i < result.length; i++) {
                if (result[i] != "") {
                    var letter = ['A', 'B', 'C', 'D'];
                    var name = result[i] + ' (Program ' + letter[i] + ')';
                    $('#programList').append('<li><a href="#" id="program' + i + '">' +
                                             name + '</a></li>');
                    $('#program' + i).click(function(i, name) {
                        return function(e) {
						    $('#programSelect').text(name);
						    $('#zoneSelect').text("");
                            startClick = function() { startProgram(i); };
                            console.log("prog " + i);
                        }
                    }(i, name));
                }
            }
        }
    }, function() {
        error("Unable to retrieve programs");
    });
}

function initZones()
{
    // Call ERPC getZones() to retrieve all of the zones
    erpc("getZones", null, function(result) {
        if (result) {
            // For each zone, insert it in the zone drop down list
            for (var i = 0; i < result.length; i++) {
                if (result[i] != "") {
                    var name = result[i] + ' (Zone ' + (i + 1) + ')';
                    $('#zoneList').append('<li><a href="#" id="zone' + i + '">' +
                                          name + '</a></li>');
                    $('#zone' + i).click(function(i, name) {
                        return function(e) {
						    $('#programSelect').text("");
						    $('#zoneSelect').text(name);
                            startClick = function() { startZone(i); };
                            console.log("zone " + i);
                        }
                    }(i, name));
                }
            }
        }
    }, function() {
        error("Unable to retrieve zones");
    });
}

// Convert minutes to an HOUR:MIN format string
function minsToHourMin(mins)
{
	return mins / 60 + ':' + mins;
}

// Initialize the controls
initControls();

// Initialize the programs
initPrograms();

// Initialize the zones
initZones();

