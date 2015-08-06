// IMU Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
require(["system", "string", "math", "I2C", "nv"]);

dofile("sd:/lib/sensors/FXOS8700/fxos8700.nut");
dofile("sd:/lib/sensors/fxas21002/fxas21002.nut");
dofile("sd:/lib/algorithms/madgwickahrs/MadgwickAHRS.nut");

// Use I2C0 at 400khz
i2c <- I2C(0);
i2c.speed(400000);

// Create the sensor instances
fxos8700 <- FXOS8700(i2c, 0x1e);
fxas21002 <- FXAS21002(i2c, 0x20);

// Madgwick AHRS filter
ahrs <- MadgwickAHRS(50);
ahrs.setBeta(0.2);

// Global sensor data
accel <- {};
mag <- {};
gyro <- {};

// ERPC function to return current IMU state
function readIMU()
{
    return {
        accel = accel,
        mag = mag,
        gyro = gyro,
        quaternion = ahrs.getQuaternion(),
        euler = ahrs.getEuler()
    };
}

// Run the main IMU loop
function runIMU()
{
    while (true) {
        local acount;
        local gcount;

        // Get the number of sensor readings available
        acount = fxos8700.accel_count();
        gcount = fxas21002.count();
        
        // Process all available sensor readings
        while (acount > 0 && gcount > 0) {
            // Read the sensors
            accel = fxos8700.accel_read();
            mag = fxos8700.mag_read();
            gyro = fxas21002.read();

            // Apply accelerometer zero offset calibration
            accel.x += cal_accel.x;
            accel.y += cal_accel.y;
            accel.z += cal_accel.z;

            // Apply gyron zero offset calibration
            gyro.x += cal_gyro.x;
            gyro.y += cal_gyro.y;
            gyro.z += cal_gyro.z;
            
            // Apply magnetometer soft-iron calibration
           	mag.x = mag.x*cal_mag.x[0] + mag.y*cal_mag.x[1] + mag.z*cal_mag.x[2];
           	mag.y = mag.x*cal_mag.y[0] + mag.y*cal_mag.y[1] + mag.z*cal_mag.y[2];
           	mag.z = mag.x*cal_mag.z[0] + mag.y*cal_mag.z[1] + mag.z*cal_mag.z[2];
                    
            // Update the AHRS filter
            ahrs.update(gyro.x, gyro.y, gyro.z,
                        accel.x,  accel.y, accel.z,
                        mag.x, mag.y, mag.z);

            acount--;
            gcount--;
        }

        // Remove any excess samples to keep both devices in sync
        for (;acount > 1; acount--)
            fxos8700.accel_readblob();

        for (;gcount > 1; gcount--)
            fxas21002.readblob();

        // Give ourselves some time to process ERPC
        delay(5);
    }
}

// Initialize the IMU calibration table if it is not in NVRAM
if (!("imu" in nv)) {
    nv.imu <- {
        accel={x=0, y=0, z=0},
        gyro={x=0, y=0, z=0},
        mag={
            x=[1, 0, 0],
            y=[0, 1, 0],
            z=[0, 0, 1]
        }
    };
}

// Add global references to calibration values
cal_accel <- nv.imu.accel;
cal_gyro <- nv.imu.gyro;
cal_mag <- nv.imu.mag;

print("Calibration:\n");
print(format("gyro %f %f %f\n",
             cal_gyro.x, cal_gyro.y, cal_gyro.z));
print(format("accel %f %f %f\n",
             cal_accel.x, cal_accel.y, cal_accel.z));
print("mag\n");
print(format("[%f %f %f]\n",
             cal_mag.x[0], cal_mag.x[1], cal_mag.x[2]));
print(format("[%f %f %f]\n",
             cal_mag.y[0], cal_mag.y[1], cal_mag.y[2]));
print(format("[%f %f %f]\n",
             cal_mag.z[0], cal_mag.z[1], cal_mag.z[2]));

runIMU();
