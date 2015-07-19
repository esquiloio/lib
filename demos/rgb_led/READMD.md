RGB LED Demo
============
The RGB LED demo lets you control the color of an RGB LED attached to your
Esquilo from any web browser.

You need an RGB LED connected to your Esquilo with current-limiting resistors
to run this demo. I used one of these, but any common-cathode one with similar
voltage requirements shoudl work:

[DFRobot RGB LED](http://dfrobot.com/wiki/index.php/Triple_Output_LED_RGB_\(SKU:FIT0095\))

You also need current limiting resistors for the three color connections.
 
| Esquilo Pin  | RGB LED Pin  | Notes                              |
| ------------ |--------------|------------------------------------|
| 2 (PWM0:CH0) |  Red         | ~100 Ohm current-limiting resistor |
| 3 (PWM0:CH1) |  Green       | ~22 Ohm current-limiting resistor  |
| 4 (PWM0:CH2) |  Blue        | ~22 Ohm current-limiting resistor  | 
| GND          |  GND         |                                    |

The demo consists of three main files:

  * rgb_led.nut - Squirrel nut that contains the Squirrel code that responds to
    ERPC requests from the JavaScript web interface to control the color.
  * rgb_led.html - Contains the HTML and JavaScript for the web interface.
  * rgb_led.css  - Cascading style sheet for the web interface.

The following Squirrel libraries are required by the demo. Ensure they are
enabled in the System menu before running weather.nut.

  * system
  * math
  * PWM

You must run the rgb_led.nut Squirrel nut on your Esquilo prior to opening
the web interface from your browser. To run this nut when Esquilo boots, you
can load it from your boot.nut with the dofile command.  i.e.

    dofile("sd:/lib/demos/rgb_led/rgb_led.nut");

After the squirrel nut runs, open the html file from your browser either
from it's local IP address:

    http://<Local Esquilo IP>/sd/lib/demos/rgb_led/rgb_led.html

License
-------
This work is released under the Creative Commons Zero (CC0) license.
See http://creativecommons.org/publicdomain/zero/1.0/

