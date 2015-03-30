// IMU Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

dofile("sd:/sensors/fxos8700/fxos8700.nut");
dofile("sd:/sensors/fxas21002/fxas21002.nut");
dofile("sd:/algorithms/madgwickahrs/madgwickahrs.nut");

// Use I2C0 at 400khz
i2c <- I2C(0);
i2c.speed(400000);

// Create the sensor instances
fxos8700 <- FXOS8700(i2c, 0x1e);
fxas21002 <- FXAS21002(i2c, 0x20);

// Madgwick AHRS filter
ahrs <- MadgwickAHRS(25);
//ahrs.setBeta(0.1);

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
        euler = ahrs.getEuler()
    };
}

// Calibrate the IMU
function calibrateIMU(samples)
{
    local acount = 0;
    local gcount = 0;
    
    // Clear all samples from the FIFOs
    while (fxos8700.accel_count() > 0)
        fxos8700.accel_readblob();

    while (fxas21002.count() > 0)
        fxas21002.readblob();
    
    // Zero calibration values
    cal_accel.x = 0;
    cal_accel.y = 0;
    cal_accel.z = 0;

    cal_gyro.x = 0;
    cal_gyro.y = 0;
    cal_gyro.z = 0;

    // Accumulate the samples request
    while (acount < samples || gcount < samples) {
        while (acount < samples && fxos8700.accel_count() > 0) {
            local accel = fxos8700.accel_read();
            cal_accel.x += accel.x;
            cal_accel.y += accel.y;
            cal_accel.z += accel.z;
            acount++;
        }

        while (gcount < samples && fxas21002.count() > 0) {
            local gyro = fxas21002.read();
            cal_gyro.x += gyro.x;
            cal_gyro.y += gyro.y;
            cal_gyro.z += gyro.z;
            gcount++;
        }

        delay(5);
    }
    
    // Calculate the offset from the mean
    cal_accel.x = -cal_accel.x / samples;
    cal_accel.y = -cal_accel.y / samples;
    cal_accel.z = -cal_accel.z / samples + 1;
    
    cal_gyro.x = -cal_gyro.x / samples;
    cal_gyro.y = -cal_gyro.y / samples;
    cal_gyro.z = -cal_gyro.z / samples;
    
    nvsave();
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

            // Add the calibration values
            accel.x += cal_accel.x;
            accel.y += cal_accel.y;
            accel.z += cal_accel.z;

            gyro.x += cal_gyro.x;
            gyro.y += cal_gyro.y;
            gyro.z += cal_gyro.z;

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
        gyro={x=0, y=0, z=0}
    };
}

// Add global references to calibration values
cal_accel <- nv.imu.accel;
cal_gyro <- nv.imu.gyro;

print(format("calibration gyro %f %f %f accel %f %f %f\n",
             cal_gyro.x, cal_gyro.y, cal_gyro.z,
             cal_accel.x, cal_accel.y, cal_accel.z));

runIMU();
