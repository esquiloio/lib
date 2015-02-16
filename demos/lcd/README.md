LCD Demo
========
The LCD demo shows remote control of an RGB LCD module using a third-party
mobile app.

# Requirements

The demo uses a Newhaven serial RGB LCD module hooked up to the Esquilo's UART0
for LCD control and PWM1 channels 0-2 for controlling the RGB backlight. The
compatible LCD modules are NHD-0216K3Z-FS(RGB)-FBW-V3 (positive display) and
NHD-0216K3Z-NS(RGB)-FBW-V3 (negative display). Please see their website for more
info:

http://www.newhavendisplay.com/serial-displays-c-253.html

For remote control, the demo uses the NetIO mobile app. NetIO sells a native
mobile application for both Android and iOS devices that lets you create custom
control interfaces using a UI designer application on their website. The custom
interface you build is called a "user config". These configs can be exported and
imported as JSON files from the UI designer. The user config for this demo is in
the *RemoteLCD.json* file. Please see their website for more info:

http://netioapp.com

> Before purchasing the NetIO app for your device, please note that this demo
uses the *textinput* and *colorpicker* widgets - neither are supported in the
current iOS version. At the time of this writing, you must use an Android device
to run the demo.

# Running the Demo

### Hardware Hookup

Connect the LCD module to your Esquilo like so:

| Esquilo Pin  | Newhaven LCD Pin        | Notes
| ------------ |-------------------------|------------------------------------|
| 1 (UART0 TX) |  J1:1 (RS-232 RX)       |                                    |
| GND          |  J1:2 (RS-232 VSS)      |                                    |
| 5V           |  J1:3 (RS-232 VDD       |                                    |
| GND          |  J3:1 (Backlight GND)   |                                    |
| 6 (PWM1:CH0) |  J3:2 (Backlight Red)   | ~33 Ohm current-limiting resistor  |
| 7 (PWM1:CH1) |  J3:3 (Backlight Green) | ~120 Ohm current-limiting resistor |
| 8 (PWM1:CH2) |  J3:4 (Backlight Blue)  | ~120 Ohm current-limiting resistor |

### NetIO App Installation

Buy the Android NetIO app and install it (the demo uses the *textinput* and
*colorpicker* widgets - neither are supported in the current iOS version).

Create an account on the NetIO site (http://netioapp.com) and sign in to
their UI Designer web app (called 'Design Editor' on the landing page).

Import the demo interface file (RemoteLCD.json) by clicking on the "Upload"
menu button, and save it by clicking on the "Save Online" menu button.

You should now have a "Remote LCD" user config available for download to your
mobile running the NetIO app. Get your Android device and open the NetIO app. In
the NetIO mobile app, swipe from the left side of the screen to the right
to bring up the account menu. Enter your account credentials and press "SYNC".
The "Remote LCD" user config should show up below the sign in fields.

Connect your Android device to your Esquilo's access point. This is necessary
because the NetIO must be configured to connect to a pre-determined IP address.
For convenience, this has been set to the default Esquilo access point address
of 10.10.10.1.

> If you'd like to keep your Android device on the local Wi-Fi, determine the IP
  address of your Esquilo's Wi-Fi interface and update the NetIO Remote LCD user
  config to use that address. This can be done in the "Global" tab in the NetIO
  UI Designer app, by changing the Connections->hostname field. For such changes
  to make it to your Android device, you need to save them with "Save Online"
  from UI Designer and download them with "SYNC" from the mobile app account
  dialog.

### Run the Squirrel Code

Bring up the Web IDE from your Esquilo, and run the "lcd.nut" file. Even
though the nut runs and exits, the LCD control functions are still loaded in the
Squirrel VM and can be called from the NetIO mobile app.

Optionally, you can run this nut when Esquilo boots by loading it from your
boot.nut with the dofile command:

`dofile("sd:/lib/demos/lcd/lcd.nut");`


### Remote Control

Restart the NetIO app on your Android device, bring up the account dialog
with the right-swipe, and tap on "Remote LCD" to start the control application.

# License

This work is released under the Creative Commons Zero (CC0) license.
See http://creativecommons.org/publicdomain/zero/1.0/