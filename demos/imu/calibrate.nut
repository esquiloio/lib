// IMU Calibration Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
dofile("sd:/sensors/FXOS8700/fxos8700.nut");
dofile("sd:/sensors/fxas21002/fxas21002.nut");

// Use I2C0 at 400khz
i2c <- I2C(0);
i2c.speed(400000);

// Create the sensor instances
fxos8700 <- FXOS8700(i2c, 0x1e);
fxas21002 <- FXAS21002(i2c, 0x20);

// Calibrate the IMU zero offsets
//
// Place the Esquilo on a flat surface with the component side facing
// up.  Run the calibrateZero() function and the zero calibration is
// saved to NVRAM.
function calibrateZero()
{
    local acount = 0;
    local gcount = 0;
    local samples = 100;
    
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
    
    print(format("gyro %f %f %f\n",
                 cal_gyro.x, cal_gyro.y, cal_gyro.z));
    print(format("accel %f %f %f\n",
                 cal_accel.x, cal_accel.y, cal_accel.z));
}

// How to calibrate the magnetometer soft-iron compensation
//
// Download and follow the directions for a magnetometer calibration
// program like MagMaster.  Run the generateMag() function to generate
// averaged magnetometer samples that MagMaster can read over a serial
// port from UART0.  Once complete, save the transformation matrix
// values to NVRAM with the saveMag() function.
function generateMag()
{
    local mag_accum = {};
    local prog = GPIO(46);
    local samples = 25;
    
    prog.input();
    
   	local serial = UART(0);
    serial.speed(9600);
    
    // Print calibration values until PROG is pressed
    print("Press PROG when calibration is complete.\n");
    while (prog.ishigh()) {
        mag_accum.x <- 0.0;
        mag_accum.y <- 0.0;
        mag_accum.z <- 0.0;
        
        for (local i = 0; i < samples; i++) {
            while (fxos8700.mag_count() == 0) {
                delay(5);
            }
            
            local mag = fxos8700.mag_read();
            
            mag_accum.x += mag.x;
            mag_accum.y += mag.y;
            mag_accum.z += mag.z;
        }
        serial.writestr(format("%f,%f,%f\r\n",
                               mag_accum.x / samples,
                               mag_accum.y / samples,
                               mag_accum.z / samples));
    }
}

function saveMag(x, y, z)
{
    cal_mag.x = x;
    cal_mag.y = y;
    cal_mag.z = z;
    nvsave();
    
    print("Magnetometer calibration saved\n");
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
