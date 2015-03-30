Sprinkler Controller Demo
=========================
The sprinkler controller demo shows how to run an autonomous task on your
Esquilo that functions independently from the web interface.  It uses the
squirrel Timer class to run asynchronous timers in the background to control
the sprinkler zones.  The web interface is used to both configure the
schedule for the zones and to immediately control their operation.

The demo consists of four files:

  * sprinkler.nut - Squirrel nut that contains the squirrel code that runs
    timers in the background to activate zones and provides ERPC functions
    that allows the web interface to configure and control the zones.
  * sprinkler.html - Contains the HTML for the web interface.
  * sprinkler.js - Contains the JavaScript code to manage the web interface
    and to send ERPC requests to the Esquilo.
  * sprinkler.css - Cascading style sheet for the web interface.

You must run the sprinkler.nut squirrel nut on your Esquilo prior to opening
the web interface from your browser.  Even though the nut runs and exits,
the functions are still loaded in the squirrel VM and can be called from the
web interface.  To run this nut when Esquilo boots, you can load it from your
boot.nut with the dofile command.  i.e.

    dofile("sd:/lib/demos/sprinkler/sprinkler.nut");

After the squirrel nut runs, open the html file from your browser either
from it's local IP address:

    http://<Local Esquilo IP>/sd/lib/demos/sprinkler/sprinkler.html

or from the Esquilo Nest:

    http://<Esquilo System ID>.esquilo.io/sd/lib/demos/sprinkler/sprinkler.html

License
-------
This work is released under the Creative Commons Zero (CC0) license.
See http://creativecommons.org/publicdomain/zero/1.0/

