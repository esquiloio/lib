IMU Demo
========
The IMU demo shows how to implement a simple attitude and heading reference
system (AHRS) on Esquilo using nine degrees of freedom (9DOF) sensors.  The
sensors provide X, Y, and Z measurements for linear acceleration, rotational
acceleration, and magnetic field strength.  The demo continuously calculates
the roll, pitch, and yaw of Esquilo using the Madgwick quaternion fusion
algorithm.  The web interface displays the roll, pitch, and yaw angles
calculated and also graphs the primitive readings from the nine sensor inputs.

A calibration button performs a single axis, zero offset calibration for
the linear and rotational accelerations.  Prior to calibrating, rest the
Esquilo on a solid flat surface with the sensors facing up.  The calibration
values are stored in EEPROM non-volatile memory and are read every time
Esquilo boots.

The sensors used for the demo are the Freescale FXOS8700CQ linear
accelerometer/magnetometer and Freescale FXAS21002 gyroscope.  Both of these
sensors are included on the Freescale FRDM-STBC-AGM01 Arduino shield board.

[FRDM-STBC-AGM01](http://www.freescale.com/webapp/sps/site/prod_summary.jsp?code=FRDM-STBC-AGM01)

The IMU board has a jumper block to select which I2C it is connected to. This
demo uses I2C0, so ensure J6 and J7 are both strapped to pins 1-2.

The demo consists of four files:

  * imu.nut - Squirrel nut that contains the squirrel code that continuously
    reads the sensors and calculates the orientation.
  * imu.html - Contains the HTML for the web interface.
  * imu.css - Cascading style sheet for the web interface.

The following Squirrel libraries are required by the demo. Ensure they are
enabled in the System menu before running imu.nut.

  * system
  * string
  * math
  * I2C
  * nv

You must run the imu.nut squirrel nut on your Esquilo prior to opening
the web interface from your browser.  To run this nut when Esquilo boots,
you can load it from your boot.nut with the dofile command.  i.e.

    dofile("sd:/lib/demos/imu/imu.nut");

After the squirrel nut is running, open the html file from your browser either
from it's local IP address:

    http://<Local Esquilo IP>/sd/lib/demos/imu/imu.html

or from the Esquilo Nest:

    http://<Esquilo System ID>.esquilo.io/sd/lib/demos/imu/imu.html

License
-------
This work is released under the Creative Commons Zero (CC0) license.
See http://creativecommons.org/publicdomain/zero/1.0/

