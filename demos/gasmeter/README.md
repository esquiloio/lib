Gas Meter Demo
==============
The gas meter demo shows you how to create a smart WiFi gas meter that you
can use to graph your natural gas or propane usage as well as monitoring
your bill and greenhouse gas emissions.

The demo requires the input of a single TTL pulse signal from a gas meter
that indicates a unit of usage, typically at 1.0 cubic feet per pulse.  If
your gas company owns your meter, then you probably won't have access to a
pulse signal but you may be able to purchase and install a second gas meter
after the gas company's meter to get a pulse signal.  Here is an example of
a pulse output gas meter:

[Pulse Output Gas Meter](http://www.amazon.com/Pulse-Output-Gas-Meter/dp/B00998ULE4)

**WARNING!!!!**
Natural gas and propane are highly flammable and very dangerous.  Misuse can
cause property damage, injury, or death.  Do not try to install a gas meter
if you do not know exactly what you are doing.  Consult a gas professional
or ask your gas company if in doubt.

The demo consists of four files:

  * gasmeter.nut - Squirrel nut that contains the squirrel code that monitors
    the pulse input from the meter and accumulates the counts.
  * gasmeter.html - Contains the HTML for the web interface using FLOT to
    display a nice graph of the gas meter data.
  * gasmeter.css - Cascading style sheet for the web interface.

The following Squirrel libraries are required by the demo. Ensure they are
enabled in the System menu before running gasmeter.nut.

  * system
  * GPIO
  * nv

You must run the gasmeter.nut squirrel nut on your Esquilo prior to opening
the web interface from your browser.  To run this nut when Esquilo boots,
you can load it from your boot.nut with the dofile command.  i.e.

    dofile("sd:/lib/demos/gasmeter/gasmeter.nut");

After the squirrel nut is running, open the html file from your browser either
from it's local IP address:

    http://<Local Esquilo IP>/sd/lib/demos/gasmeter/gasmeter.html

or from the Esquilo Nest:

    http://<Esquilo System ID>.esquilo.io/sd/lib/demos/gasmeter/gasmeter.html

License
-------
This work is released under the Creative Commons Zero (CC0) license.
See http://creativecommons.org/publicdomain/zero/1.0/

