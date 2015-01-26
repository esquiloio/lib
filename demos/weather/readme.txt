Weather Station Demo
====================
The weather station demo shows a live view of the current weather conditions
at your Esquilo from any web browser.  The demo utilizes three sensor
devices:

  * Freescale MPL3115A2 for barometric pressure
  * Measurement Specialties HTU21D-F for humidity
  * Microchip MCP9808 for temperature

All three sensor devices must be installed on the I2C0 bus on your Esquilo.

The demo consists of three files:

  * weather.nut - Squirrel nut that contains the squirrel code that responds to
    ERPC requests from the JavaScript web interface.
  * weather.html - Contains the HTML and JavaScript for the web interface.
  * weather.css - Cascading style sheet for the web interface.

You must run the weather.nut squirrel nut on your Esquilo prior to opening
the web interface from your browser.  Even though the nut runs and exits,
the functions are still loaded in the squirrel VM and can be called from the
web interface.  To run this nut when Esquilo boots, you can load it from your
boot.nut with the dofile command.  i.e.

    dofile("sd:/lib/demos/weather/weather.nut");

After the squirrel nut runs, open the html file from your browser either
from it's local IP address:

    http://<Local Esquilo IP>/sd/lib/demos/weather/weather.html

or from the Esquilo Nest:

    http://esquilo.io/nest/<Esquilo System ID>/sd/lib/demos/weather/weather.html

License
-------
This work is release under the Creative Commons Zero (CC0) license.
See http://creativecommons.org/publicdomain/zero/1.0/

