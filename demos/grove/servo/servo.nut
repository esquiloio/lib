// Rotary Servo Demo
//
// Ported from:
//   https://github.com/Seeed-Studio/Sketchbook_Starter_Kit_V2.0
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

// Controls a servo's position from a web app slider
//
// Connect the Grove Servo to the socket marked D3
// Set the Grove Base Shield VCC switch to 5.0V
require("PWM");
dofile("sd:/motors/servo/servo.nut");

pwm   <- PWM(0);
servo <- Servo(pwm, 1);

position <- 0;  // Degrees

// ERPC to set the position from the web app
function setPosition(value)
{
    position = value;
}

while(true) {
    servo.position(position);
    delay(50);
}