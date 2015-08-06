/////////////////////////////////////////////////////////////////////////////
// Mahony Attitude Heading Reference System (AHRS) algorithm
// for IMU sensors with 9 degrees of freedom (accel + mag + gyro)
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
require("math");

class MahonyAHRS
{
    sampleFreq = 0;
    twoKp = 1.0;
    twoKi = 0.0;
    q0 = 1.0;
    q1 = 0.0;
    q2 = 0.0;
    q3 = 0.0;
    integralFBx = 0.0;
    integralFBy = 0.0;
    integralFBz = 0.0;
}

function MahonyAHRS::constructor(_sampleFreq)
{
    sampleFreq = _sampleFreq;
}

function MahonyAHRS::setGains(kp, ki)
{
    twoKp = 2.0 * kp;
    twoKi = 2.0 * ki;
}

function MahonyAHRS::getQuaternion()
{
    return [ q0, q1, q2, q3 ];
}

function MahonyAHRS::getEuler()
{
    local roll  = atan2(2*(q0*q1 + q2*q3), 1 - 2*(q1*q1 + q2*q2));
    local pitch = asin(2*(q0*q2 - q3*q1));
	local yaw   = atan2(2*(q0*q3 + q1*q2), 1 - 2*(q2*q2 + q3*q3));

    return { roll = roll, pitch = pitch, yaw = yaw };
}

function MahonyAHRS::invSqrt(x)
{
    return 1.0 / sqrt(x);
}

function MahonyAHRS::update(gx, gy, gz, ax, ay, az, mx, my, mz)
{
	local recipNorm;
    local q0q0, q0q1, q0q2, q0q3, q1q1, q1q2, q1q3, q2q2, q2q3, q3q3;  
	local hx, hy, bx, bz;
	local halfvx, halfvy, halfvz, halfwx, halfwy, halfwz;
	local halfex, halfey, halfez;
	local qa, qb, qc;

	if((mx == 0.0) && (my == 0.0) && (mz == 0.0))
		return;
    
	// Compute feedback only if accelerometer measurement valid (avoids NaN in accelerometer normalisation)
	if(!((ax == 0.0) && (ay == 0.0) && (az == 0.0))) {

		// Normalise accelerometer measurement
		recipNorm = invSqrt(ax * ax + ay * ay + az * az);
		ax *= recipNorm;
		ay *= recipNorm;
		az *= recipNorm;     

		// Normalise magnetometer measurement
		recipNorm = invSqrt(mx * mx + my * my + mz * mz);
		mx *= recipNorm;
		my *= recipNorm;
		mz *= recipNorm;   

        // Auxiliary variables to avoid repeated arithmetic
        q0q0 = q0 * q0;
        q0q1 = q0 * q1;
        q0q2 = q0 * q2;
        q0q3 = q0 * q3;
        q1q1 = q1 * q1;
        q1q2 = q1 * q2;
        q1q3 = q1 * q3;
        q2q2 = q2 * q2;
        q2q3 = q2 * q3;
        q3q3 = q3 * q3;   

        // Reference direction of Earth's magnetic field
        hx = 2.0 * (mx * (0.5 - q2q2 - q3q3) + my * (q1q2 - q0q3) + mz * (q1q3 + q0q2));
        hy = 2.0 * (mx * (q1q2 + q0q3) + my * (0.5 - q1q1 - q3q3) + mz * (q2q3 - q0q1));
        bx = sqrt(hx * hx + hy * hy);
        bz = 2.0 * (mx * (q1q3 - q0q2) + my * (q2q3 + q0q1) + mz * (0.5 - q1q1 - q2q2));

		// Estimated direction of gravity and magnetic field
		halfvx = q1q3 - q0q2;
		halfvy = q0q1 + q2q3;
		halfvz = q0q0 - 0.5 + q3q3;
        halfwx = bx * (0.5 - q2q2 - q3q3) + bz * (q1q3 - q0q2);
        halfwy = bx * (q1q2 - q0q3) + bz * (q0q1 + q2q3);
        halfwz = bx * (q0q2 + q1q3) + bz * (0.5 - q1q1 - q2q2);  
	
		// Error is sum of cross product between estimated direction and measured direction of field vectors
		halfex = (ay * halfvz - az * halfvy) + (my * halfwz - mz * halfwy);
		halfey = (az * halfvx - ax * halfvz) + (mz * halfwx - mx * halfwz);
		halfez = (ax * halfvy - ay * halfvx) + (mx * halfwy - my * halfwx);

		// Compute and apply integral feedback if enabled
		if(twoKi > 0.0) {
			integralFBx += twoKi * halfex * (1.0 / sampleFreq);	// integral error scaled by Ki
			integralFBy += twoKi * halfey * (1.0 / sampleFreq);
			integralFBz += twoKi * halfez * (1.0 / sampleFreq);
			gx += integralFBx;	// apply integral feedback
			gy += integralFBy;
			gz += integralFBz;
		}
		else {
			integralFBx = 0.0;	// prevent integral windup
			integralFBy = 0.0;
			integralFBz = 0.0;
		}

		// Apply proportional feedback
		gx += twoKp * halfex;
		gy += twoKp * halfey;
		gz += twoKp * halfez;
	}
	
	// Integrate rate of change of quaternion
	gx *= (0.5 * (1.0 / sampleFreq));		// pre-multiply common factors
	gy *= (0.5 * (1.0 / sampleFreq));
	gz *= (0.5 * (1.0 / sampleFreq));
	qa = q0;
	qb = q1;
	qc = q2;
	q0 += (-qb * gx - qc * gy - q3 * gz);
	q1 += (qa * gx + qc * gz - q3 * gy);
	q2 += (qa * gy - qb * gz + q3 * gx);
	q3 += (qa * gz + qb * gy - qc * gx); 
	
	// Normalise quaternion
	recipNorm = invSqrt(q0 * q0 + q1 * q1 + q2 * q2 + q3 * q3);
	q0 *= recipNorm;
	q1 *= recipNorm;
	q2 *= recipNorm;
	q3 *= recipNorm;
}
