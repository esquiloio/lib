// OScilloscope Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
var socket;
var canvas;
var context;

// Scope data
var scope = {
    channel: 0,
    state: "run",
    hscales: [ 100, 200, 500, 1000, 2000, 5000, 10000, 20000, 50000, 100000 ],
	vscales: [ 5.0, 2.0, 1.0, 0.5, 0.2, 0.1, 0.05, 0.02, 0.01 ]
};

// Channel data
var channel = [
    {
        data: null,
        enable: true,
        vscale: 0.5,
        voffset: 0,
        color: "#ff0"
	},
    {
        data: null,
        enable: true,
        vscale: 0.5,
        voffset: 0,
        color: "#0ff"
	}
];

// Number of divisions in the scope display
var XDIVS = 16;
var YDIVS = 10;

// Offset of the scope display in the canvas
var XOFFSET = 20;
var YOFFSET = 20;
var FOOTER = 60;

// Set to match Esquilo ADC
var SAMPLE_BITS = 12;
var SAMPLE_VRANGE = 3.3;

// Draw a rectangle with rounded corners using the current fill and stroke
function drawRect(x, y, width, height, radius)
{
    context.beginPath();
    context.moveTo(x + radius, y);
    context.lineTo(x + width - radius, y);
    context.quadraticCurveTo(x + width, y, x + width, y + radius);
    context.lineTo(x + width, y + height - radius);
    context.quadraticCurveTo(x + width, y + height, x + width - radius, y + height);
    context.lineTo(x + radius, y + height);
    context.quadraticCurveTo(x, y + height, x, y + height - radius);
    context.lineTo(x, y + radius);
    context.quadraticCurveTo(x, y, x + radius, y);
    context.closePath();
    context.fill();
    context.stroke();
}

// Draw a text box in the default scope styling with
// the given text string and text color
function drawTextBox(x, y, width, height, text, color)
{
    context.save();
    
    context.translate(x, y);
    
    context.strokeStyle="#aaa";
    context.fillStyle="#000";
    drawRect(0, 0, width, height, 10);
    
    context.font = "24px sans-serif";
	context.fillStyle = color;
    context.fillText(text, 10, 23);
    
    context.restore();
}

// Draw the vertical scale text box for the given channel number
function drawVscale(num)
{
    var units;
    
    // Normalize units
    var vscale = channel[num].vscale;
    if (vscale < 0.001) {
        vscale *= 1000000;
        units = "uV";
    }
    else if (vscale < 1) {
        vscale *= 1000;
        units = "mV";
    }
    else {
        units = "V";
    }

    // Draw the text box in the footer area
    drawTextBox(XOFFSET + num * (scope.width / 4 + XOFFSET),
                canvas.height - FOOTER + 10,
                scope.width / 4,
                30,
                "CH" + (num + 1) + " " + vscale + units,
                channel[num].color);
}

// Draw the horizontal scale text box
function drawHscale()
{
    var units;
    
  	color = "#fff";
    
    // Normalize units
    var hscale = scope.hscale;
    if (hscale >= 1000) {
        hscale /= 1000;
        units = "mS";
    }
    else {
        units = "uS";
    }
    
    // Draw the text box in the footer area
    drawTextBox(XOFFSET + 3 * scope.width / 4,
                canvas.height - FOOTER + 10,
                scope.width / 4,
                30,
                hscale + units,
                color);
}

// Draw the screen minus the scope display
function drawScreen()
{
    context.save();
    context.strokeStyle="#aaa";
    context.fillStyle="#000";
    context.strokeRect(XOFFSET - 1, YOFFSET - 1, scope.width + 2, scope.height + 2);
    context.restore();
}

// Clear the scope display
function clearScope()
{
    context.save();
    
    // Offset scope display from the screen edge
    context.translate(XOFFSET, YOFFSET);

    // Set the clipping region to keep everything in the scope display
    context.beginPath();
   	context.rect(0, 0, scope.width, scope.height);
    context.stroke();
    context.clip();
    
    // Erase the scope display
    context.fillStyle="#000";
    context.fillRect(0, 0, scope.width, scope.height);
    
    // Dotted lines are grey
    context.strokeStyle="#555";
    
    // Draw 5 dots per division with 2 pixel dots
	context.setLineDash([2, (scope.width / XDIVS / 5) - 2]);

    // Draw horizontal dotted lines
    var xdiv = scope.width / XDIVS;
    for (var x = xdiv; x < scope.width; x += xdiv) {
        context.beginPath();
        context.moveTo(x, -1);
        context.lineTo(x, scope.height + 1);
        context.stroke();
    }

    // Draw 5 dots per division with 2 pixel dots
  	context.setLineDash([2, (scope.height / YDIVS / 5) - 2]);

    // Draw vertical dotted lines
    var ydiv = scope.height / YDIVS;
    for (var y = ydiv; y < scope.height; y += ydiv) {
        context.beginPath();
        context.moveTo(-1, y);
        context.lineTo(scope.width + 1, y);
        context.stroke();
    }
    
    context.restore();
}

// Draw the data for a channel on the scope display
function drawChannel(num)
{
    context.save();
    
    // Offset scope display from the screen edge
    context.translate(XOFFSET, YOFFSET);
    
    // Interpret the raw data as unsigned 16-bit integers
    var samples = new Uint16Array(channel[num].data);

    // Set the clipping region to keep everything in the scope display
    context.beginPath();
   	context.rect(0, 0, scope.width, scope.height);
    context.stroke();
    context.clip();

    // Calculate the channel vertical offset
    var yoffset = scope.height - channel[num].voffset - 1;
    
    // Calculate the pixel scale factor
    var yscale =  (SAMPLE_VRANGE / (1 << SAMPLE_BITS)) * (scope.height / YDIVS) / channel[num].vscale;

    // Draw all the data points as a path on the canvas
  	context.strokeStyle = channel[num].color;
    context.beginPath();
    for (var x = 0; x < scope.width && x < samples.length; x++) {
	    var y = yoffset - samples[x] * yscale;
        if (x == 0)
            context.moveTo(x, y);
        else
            context.lineTo(x, y);
    }
    context.stroke();
    
    context.restore();
}

// Connect to the Esquilo via a WebSocket
function connect()
{
    socket = new WebSocket("ws://" + window.location.hostname + "/websocket");
    socket.binaryType = "arraybuffer";
    
    // Set the scope parameters every time we open a connection
    socket.onopen = function(){
	    erpc("setHscale", scope.hscale);
        erpc("setChannels", [ channel[0].enable, channel[1].enable ]);
    }

    // Handle arriving data
    socket.onmessage = function(msg){
        // A one byte message is the channel number which precedes the data
        if (msg.data.byteLength == 1) {
            // Extract the channel number
            var bytes = new Uint8Array(msg.data)
            var num = bytes[0];
            
            // If the scope is running and this is the first channel or a repeat
            // channel, then draw the channel data we've gotten so far
            if (scope.state != "stop" && (num == scope.channel || num == 0)) {
                // Clear the display if not starting single capture mode
                if (scope.state != "single")
            		clearScope();
                
                // Draw channel 1 data
                if (channel[0].enable && channel[0].data) {
					drawChannel(0);
	                channel[0].data = null;
                }
                
                // Draw channel 2 data
                if (channel[1].enable && channel[1].data) {
					drawChannel(1);
                	channel[1].data = null;
                }
                
                // If in single capture mode, trigger the capture
                if (scope.state == "single") {
                    scope.state = "capture";
                }
                // We're done with single capture so turn off the channels and stop
                else if (scope.state == "capture") {
                    scope.state = "stop";
			        erpc("setChannels", [ false, false ]);
                }
            }
            // Save the channel number
            scope.channel = num;
        }
        else {
            // Save the channel data
           	channel[scope.channel].data = msg.data;
        }
    }

    // Retry the connection if it closes
    socket.onclose = function(){
        socket = null;
        setTimeout(function() { connect(); }, 1000);
    }
    
    socket.onerror = function(){
    }
}

// Initialization after the page is loaded
window.addEventListener('load', function() {
    
    // Create the canvas its context
    canvas = document.getElementById("canvas");
    context = canvas.getContext("2d");
    
    // Translate by half a pixel to reduce aliasing
    context.translate(0.5, 0.5);

    // Calaculate the scope display dimensions
    scope.height = canvas.height - YOFFSET - FOOTER;
    scope.width = canvas.width - 2 * XOFFSET;
    
    // Draw the screen and scope display
    drawScreen();
    clearScope();
    
	//
    // Run/Stop button
    //
    var run = document.getElementById("run");
    run.addEventListener("change", function() {
        var single = document.getElementById("single");
        if (this.checked) {
        	erpc("setChannels", [ channel[0].enable, channel[1].enable ]);
            single.disabled = true;
        }
        else {
        	erpc("setChannels", [ false, false ]);
            single.disabled = false;
        }

        scope.state = this.checked ? "run" : "stop";
    }, false);
	run.checked = true;
    
	//
    // Single button
    //
    var single = document.getElementById("single");
    single.addEventListener("click", function() {
	    var run = document.getElementById("run");
        if (scope.state == "stop" && (channel[0].enable || channel[1].enable)) {
            scope.state = "single";
            channel[0].data = null
            channel[1].data = null
        	erpc("setChannels", [ channel[0].enable, channel[1].enable ]);
        }
    }, false);
    single.disabled = true;
    
    //
    // Horizontal scale slider
    //
    var hscale = document.getElementById("hscale");
    hscale.addEventListener("change", function() {
        scope.hscale = scope.hscales[this.value];
        erpc("setHscale", scope.hscale);
        drawHscale();
    }, false);
    hscale.value = 3;
    scope.hscale = scope.hscales[hscale.value];
    drawHscale();
    
    //
    // Channel 1 button
    //
    var chan1_enable = document.getElementById("chan1_enable");
    chan1_enable.addEventListener("change", function() {
        channel[0].enable = this.checked;
       	erpc("setChannels", [ channel[0].enable, channel[1].enable ]);
        clearScope();
    }, false);
    chan1_enable.checked = true;

    //
    // Channel 2 button
    //
    var chan2_enable = document.getElementById("chan2_enable");
    chan2_enable.addEventListener("change", function() {
        channel[1].enable = this.checked;
      	erpc("setChannels", [ channel[0].enable, channel[1].enable ]);
        clearScope();
    }, false);
    chan2_enable.checked = true;

    //
    // Channel 1 scale
    //
    var chan1_scale = document.getElementById("chan1_scale");
    chan1_scale.addEventListener("input", function() {
        channel[0].vscale = scope.vscales[this.value];        
		drawVscale(0);
    }, false);
    chan1_scale.value = 3;
	drawVscale(0);
    
    //
    // Channel 1 offset
    //
    var chan1_offset = document.getElementById("chan1_offset");
    chan1_offset.addEventListener("input", function() {
        channel[0].voffset = scope.height * this.value / 100;
    }, false);
    chan1_offset.value = 0;

    //
    // Channel 2 scale
    //
    var chan2_scale = document.getElementById("chan2_scale");
    chan2_scale.addEventListener("input", function() {
        channel[1].vscale = scope.vscales[this.value];
		drawVscale(1);
    }, false);
    chan2_scale.value = 3;
	drawVscale(1);

    //
    // Channel 2 offset
    //
    var chan2_offset = document.getElementById("chan2_offset");
    chan2_offset.addEventListener("input", function() {
        channel[1].voffset = scope.height * this.value / 100;
    }, false);
    chan2_offset.value = 0;
    
    // Connect to the Esquilo
    connect();
}, false);
