// Weather Station Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

// Read temperature from HTU21D
function readTemp() {
  i2c.address(0x40);
  local temp = i2c.read24(0xe3) >> 8;
  temp = -46.85 + 175.75 * temp / 65536.0;
  return temp;
}

// Read pressure from MPL3115A2
function readPressure() {
  i2c.address(0x60);
  while ((i2c.read8(0x0) & 0x04) == 0)
    delay(10);
  local pressure = i2c.read24(0x01) / 64.0;
  return pressure;
}

// Read humidity from HTU21D
function readHumidity() {
  i2c.address(0x40);
  local humidity = i2c.read24(0xe5) >> 8;
  humidity = -6.0 + 125.0 * humidity / 65536.0;
  return humidity;
}

function setup() {
  // Setup MPL3115A2 for pressure
  i2c.address(0x60);
  i2c.write8(0x26, 0x39);
  i2c.write8(0x13, 0x07);
}

i2c <- I2C(0);
setup();
print("Weather station ready!\n");
