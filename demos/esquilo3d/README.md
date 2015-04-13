Esquilo 3D Demo
===============
The Esquilo 3D demo shows a three dimensional Esquilo logo that moves in real
time to match the orientation of the Esquilo board.  The demo uses the exact
same Squirrel nut and sensors as the [IMU demo](../imu/).  The logo is rendered
on the browser using [WebGL](http://en.wikipedia.org/wiki/WebGL) and the
[three.js JavaScript 3D library](http://threejs.org/).

The demo consists of two files:

  * esquilo3d.html - Contains the HTML for the web interface.
  * d3-threeD.js - JavaScript library using D3 for 3 dimensional rendering.

To run the demo, follow the instructions in the [IMU demo readme](../imu/README.md),
including running imu.nut and calibrating the IMU.

After the squirrel nut is running, open the html file from your browser either
from it's local IP address:

    http://<Local Esquilo IP>/sd/lib/demos/esquilo3d/esquilo3d.html

or from the Esquilo Nest:

    http://<Esquilo System ID>.esquilo.io/sd/lib/demos/esquilo3d/esquilo3d.html

License
-------
This work is released under the Creative Commons Zero (CC0) license.
See http://creativecommons.org/publicdomain/zero/1.0/

