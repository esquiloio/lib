Weather Station Demo
====================
The weather station demo shows a live view of the current weather conditions
at your Esquilo from any web browser.  The demo utilizes two sensor
devices:

  * Freescale MPL3115A2 for barometric pressure
  * Measurement Specialties HTU21D-F for humidity and temperature

Both sensor devices must be installed on the I2C0 bus on your Esquilo.  You can
buy a ready-made Arduino shield that contains these two devices from SparkFun:

[SparkFun Weather Shield](https://www.sparkfun.com/products/12081)

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

    http://<Esquilo System ID>.esquilo.io/sd/lib/demos/weather/weather.html

License
-------
This work is released under the Creative Commons Zero (CC0) license.
See http://creativecommons.org/publicdomain/zero/1.0/

