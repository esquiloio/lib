// OScilloscope Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
var funcgen = {
    frequency: 1000,
    offset: 1.6,
    amplitude: 2.0,
    duty: 50,
    waveform: "sine"
};

function update()
{
    erpc("set", funcgen);
}

// Callback for waveform selection radio buttons
var waveform = function()
{
    // Save the value and update the Esquilo
    funcgen.waveform = this.id;
    update();
}

// Initialization after the page is loaded
window.addEventListener('load', function() {
    
    //
    // Waveform selection radio buttons
    //
    var sine = document.getElementById("sine");
    sine.checked = true;
    sine.addEventListener("change", waveform);
    
    var rampup = document.getElementById("rampup");
    rampup.addEventListener("change", waveform);
    
    var rampdown = document.getElementById("rampdown");
    rampdown.addEventListener("change", waveform);
    
    var square = document.getElementById("square");
    square.addEventListener("change", waveform);
    
    var triangle = document.getElementById("triangle");
    triangle.addEventListener("change", waveform);
    
    var pulse = document.getElementById("pulse");
    pulse.addEventListener("change", waveform);
    
    var dc = document.getElementById("dc");
    dc.addEventListener("change", waveform);
    
    var noise = document.getElementById("noise");
    noise.addEventListener("change", waveform);
    
    //
    // Frequency number input
    //
    var frequency = document.getElementById("frequency");
    frequency.value = funcgen.frequency;
    frequency.addEventListener("change", function() {
        var frequency = parseInt(this.value);
        
        // Bound the frequency to a reasonable range
        if (frequency > 10000)
            frequency = 10000;
        if (frequency < 100)
            frequency = 100;
        
        // Save the value and update the Esquilo
        this.value = frequency;
        funcgen.frequency = frequency;
        update();
    });
    
    //
    // Amplitude number input
    //
    var amplitude = document.getElementById("amplitude");
    amplitude.value = funcgen.amplitude;
    amplitude.addEventListener("change", function() {
        var amplitude = parseFloat(this.value);
        
        // Make sure the amplitude does not exceed the DAC bounds
        // when taking into account the current DC offset
        if (amplitude / 2 + funcgen.offset > 3.0)
            amplitude = 2 * (3.0 - funcgen.offset);
        if (funcgen.offset - amplitude / 2 < 0.0)
            amplitude = 2 * funcgen.offset;
        
        // Save the value and update the Esquilo
        this.value = amplitude;
        funcgen.amplitude = amplitude;
        update();
    });
    erpc("setAmplitude", amplitude.value);
    
    //
    // Offset number input
    //
    var offset = document.getElementById("offset");
    offset.value = funcgen.offset;
    offset.addEventListener("change", function() {
        var offset = parseFloat(this.value);
        
        // Make sure the DC offset does not exceed the DAC bounds
        // when taking into account the current amplitude
        if (offset + funcgen.amplitude / 2.0 > 3.0)
             offset = 3.0 - funcgen.amplitude / 2;
        if (offset - funcgen.amplitude / 2 < 0.0)
            offset = funcgen.amplitude / 2;
        
        // Save the value and update the Esquilo
        this.value = offset;
        funcgen.offset = offset;
        update();
    });

    //
    // Duty cycle number input
    //
    var duty = document.getElementById("duty");
    duty.value = funcgen.duty;
    duty.addEventListener("change", function() {
        var duty = parseInt(this.value);
        
        // Make sure the duty cycle is in range
        if (duty > 99)
             duty = 99;
        if (duty < 1)
            duty = 1;
        
        // Save the value and update the Esquilo
        this.value = duty;
        funcgen.duty = duty;
        update();
    });

    update();
});
                        