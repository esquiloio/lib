// Oscilloscope Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
require(["ADC", "WebSocket","DAC","math","string"]);

const XSIZE = 800;
const XDIV = 50;

function setChannels(params)
{
    chan0 = params[0];
    chan1 = params[1];
}
        
function setHscale(timediv)
{
    local frequency = (XDIV * 1000000 / timediv);
    
    adc0.frequency(frequency);
    // no need to change adc1 since they share the clock
}

function setup()
{
    adc0 <- ADC(0);
    buf0 <- blob(XSIZE * 2);
    chan0 <- true;
    adc0.resolution(12);

    adc1 <- ADC(1);
    buf1 <- blob(XSIZE * 2);
    chan1 <- true;
    adc1.resolution(12);
    
	setHscale(1000);
    
    server <- WebSocketServer();
}

function loop()
{
    print("waiting for connection\n");
    while (!server.available())
        delay(10);

    local socket = server.accept();
    if (socket) {
        print("connected\n");
       	socket.binary(true);

        try {
            while (socket.isconnected()) {
                local c0 = chan0;
                local c1 = chan1;
                try {
                    if (c0)
                        adc0.readblob(0, buf0);
                    if (c1)
                        adc1.readblob(0, buf1);
                    if (c0)
 	                   adc0.waitdone();
                    if (c1)
 	                   adc1.waitdone();
                }
                catch (error)
                {
                    // Continue after ADC errors
                    print(error + "\n");
                }
                if (c0) {
                    socket.write(0);
                    socket.writeblob(buf0);
                }
                if (c1) {
                    socket.write(1);
                    socket.writeblob(buf1);
                }

                delay(10);
            }
        }
        catch (error)
        {
            print(error + "\n");
        }
    }
}

setup();
while (true)
    loop();