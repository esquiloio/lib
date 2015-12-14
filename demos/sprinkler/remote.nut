// Sprinkler Remote Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/dofile("sd:/lib/buses/hunter/hunter.nut");

require("GPIO");
        
// Include the Hunter bus class
dofile("sd:/lib/buses/hunter/hunter.nut");

//
// Define your programs here.  Hunter supports 3 or 4 programs depending
// on the model.
//
programs <- [
    // Program A
    "Yards",
    // Program B
    "Flower Beds"
];

//
// Define your zones here in numerical order starting with zone 1.
//
zones <- [
    // Zone 1
    "Front Yard"
    // Zone 2
    "Front Flower Beds"
    // Zone 3
    "Back Yard"
    // Zone 4
    "Back Flower Beds"
    // Zone 5
    "Left Side Yard"
    // Zone 6
    "Right Side Yard"
];

function init()
{
    //
    // Enable the bus output
    //
    oe <- GPIO(2);
    oe.low();
    oe.output();
    
    //
    // Create the hunter instance
    //
    hunter <- Hunter(0);
}

//
// ERPC functions
//
function getZones()
{
    return zones;
}

function getPrograms()
{
    return programs;
}

function startZone(params)
{
  	hunter.start(params[0] + 1, params[1]);
}

function startProgram(params)
{
   	hunter.program(params[0] + 1);
}

function stop()
{
    hunter.stop();
}

//
// Initialize the nut
//
init();
