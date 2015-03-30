// Weather Station Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

dofile("sd:/sensors/mpl3115a2/mpl3115a2.nut");
dofile("sd:/sensors/htu21d/htu21d.nut");

// ERPC function to get the weather data
function getWeather()
{
    return {
        temp = htu21d.readTemp(),
        humidity = htu21d.readHumidity(),
        pressure = mpl3115a2.readPressure()
    };
}

// Use I2C0 bus
i2c <- I2C(0);

// Create our sensor objects
htu21d <- HTU21D(i2c, 0x40);
mpl3115a2 <- MPL3115A2(i2c, 0x60);

// Light up the LED on the weather shield
led <- GPIO(7);
led.high();
led.output();

print("Weather station ready!\n");
