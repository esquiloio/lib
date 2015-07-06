/////////////////////////////////////////////////////////////////////////////
// Generic pid class
//
// Derived entirely from the Arduino PID library 
//   http://playground.arduino.cc/Code/PIDLibrary
// and this wonderful explaination
//   http://brettbeauregard.com/blog/2011/04/improving-the-beginners-pid-introduction/
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Example usage:
//
// /* PID Controller */
//
// pid <- Pid(Kp, Ki, Kd, ControllerDirection);
// 
// /* set Output Limits  */
// pid.setOutputLimits(100,100);
//
// /* Set the ControllerDirection to reverse*/
// pid.setControllerDirection(pid.REVERSE);
//

class Pid 
{
    Input = 0.0;
    Output = 0.0;
    Setpoint = 0.0;
    Kp = 0.0;
    Ki = 0.0;
    Kd = 0.0;
    dispKp = 0.0;
    dispKi = 0.0;
    dispKd = 0.0;
    DIRECT = 0;
    REVERSE = 1;
    controllerDirection = 0;
    MANUAL = 0;
    AUTOMATIC = 1;
    inAuto = false;
    SampleTime = 1;
    SampleTimeInSec = 0.001
    now = 0;
    timeChange = 0;
    lastTime = 0;
    error = 0;
    ITerm = 0;
    outMax = 255;
    outMin = 0;
    dInput = 0
    lastInput = 0;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a Pid class instance. The parameters specified
//		here are those for which we can't setup reliable defaults,
// 		so we need to have the user set them. 
// Arguments:   _kp - loop Proportional 
//		_ki - loop Integral
//		_kd - loop Derivitive
//		_controllerDirection - DIRECT or REVERSE drive
/////////////////////////////////////////////////////////////////////////////
function Pid::constructor(_kp,_ki,_kd,_controllerDirection)
{
    SetOutputLimits(0,255);
    SetTunings(_kp,_ki,_kd);
    controllerDirection = _controllerDirection;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    Compute
// Description: This, as the say, is where the magic happens. This function
//		should be called from the main loop. The function will decide
//		for itself whether a new pid Output needs to be computed 
// Arguments:   None
/////////////////////////////////////////////////////////////////////////////
function Pid::Compute() 
{
    if (!inAuto) return;
    now = millis();
    timeChange = now - lastTime;
    if (timeChange >= SampleTime) 
    {
        error = Setpoint - Input;
        ITerm += Ki * error;
        if (ITerm > outMax) ITerm = outMax;
        else if (ITerm < outMin) ITerm = outMin;
        dInput = Input - lastInput;

	// Comput PID output
        Output = Kp * error + ITerm - Kd * dInput;
        if (Output > outMax) Output = outMax;
        else if (Output < outMin) Output = outMin;
        
        // remember some variables for next time
        lastInput = Input;
        lastTime = now;
    }
}


/////////////////////////////////////////////////////////////////////////////
// Function:    SetTunings
// Description: This function allows the controller's dymanic performace to
//		be adjusted. It's called automatically from the constructor,
//		but tunings can also be adjusted on the fly during normal 
//              operation
// Arguments:   _kp - loop Proportional 
//		_ki - loop Integral
//		_kd - loop Derivitive
/////////////////////////////////////////////////////////////////////////////
function Pid::SetTunings(_kp, _ki, _kd) 
{
    if ( _kp<0 || _ki<0 || _kd<0 ) return;
    dispKp = _kp;
    dispKi = _ki;
    dispKd = _kd;
    Kp = _kp;
    
    SampleTimeInSec = SampleTime/1000.0;
    Ki = _ki * SampleTimeInSec;
    Kd = _kd / SampleTimeInSec;
    
    if(controllerDirection == REVERSE)
    {
        Kp = 0 - Kp;
        Ki = 0 - Ki;
        Kd = 0 - Kd;
    }
}


/////////////////////////////////////////////////////////////////////////////
// Function:    SetSampleTime
// Description: Sets the period, in Milliseconds, at which the calculation
//		is performed. 
// Arguments:   _newSampleTime - New SampleTime
/////////////////////////////////////////////////////////////////////////////
function Pid::SetSampleTime(_newSampleTime)
{
    if (_newSampleTime > 0 )
    {
        local ratio = _newSampleTime / SampleTime;
        Ki *= ratio;
        Kd /= ratio;
        SampleTime = _newSampleTime;
    }
}


/////////////////////////////////////////////////////////////////////////////
// Function:    SetOutputLimits
// Description: This function will be used far more often than SetInputLimits.
//		While the input to the controller will generally be in the 
//		0-1023 range (which is the default already), the output will be 
//		a little different. Maybe they'll be doing a time window and
//		will need 0-8000 or something. Or maybe they'll want to clamp
//		from 0-125. Who Knows. At any rate, that can all be done here
// Arguments:   _min - Minimum output
//		_max - Maximum output
/////////////////////////////////////////////////////////////////////////////
function Pid::SetOutputLimits(_min, _max)
{
    if ( _min >= _max ) return;
    outMin = _min;
    outMax = _max;
    
    if(inAuto)
    {
        if ( Output > outMax ) Output = outMax;
        else if ( Output < outMin ) Output = outMin;
            
        if ( ITerm > outMax ) ITerm = outMax;
        else if ( ITerm < outMin ) ITerm = outMin;
    }
}



/////////////////////////////////////////////////////////////////////////////
// Function:    SetMode
// Description: Allows the controller Mode to be set to manual (0) or
//		Automatic (non-zero).  When the transition from manual to 
//		auto occurs, the controller is automatically initialized. 
// Arguments:   _mode - controller mode
/////////////////////////////////////////////////////////////////////////////
function Pid::SetMode(_mode)
{
    local newAuto = ( _mode == AUTOMATIC );
    if ( newAuto == !inAuto)
    {       // just went from manual to auto
        	// this triggers going from auto to manual also!
        Initialize();
    }
    inAuto = newAuto;
}


/////////////////////////////////////////////////////////////////////////////
// Function:    Initialize
// Description: Does all the things that need to happen to ensure a bumpless
//		transfer from manual to automatic mode. 
// Arguments:   None
/////////////////////////////////////////////////////////////////////////////
function Pid::Initialize()
{
    ITerm = Output;
    lastInput = Input;
    if ( ITerm > outMax ) ITerm = outMax;
    else if ( ITerm < outMin ) ITerm = outMin;
}



/////////////////////////////////////////////////////////////////////////////
// Function:    SetControllerDirection
// Description: The PID will either be connected to a DIRECT acting process
//		(+Output leads to +Input) or a REVERSE acting process (+Output 
//		leads to -Input)  We need to know which one, because otherwise
//		we may increase output when we should be decreasing. This is 
//		called from the constructor.
// Arguments:   _direction - controller direction
/////////////////////////////////////////////////////////////////////////////    
function Pid::SetControllerDirection(_direction)
{
    if ( inAuto && _direction != controllerDirection)
    {
        Kp = 0 - Kp;
        Ki = 0 - Ki;
        Kd = 0 - Kd;
    }
    controllerDirection = _direction;
}


/////////////////////////////////////////////////////////////////////////////
// Function:    Status
// Description: Just because you set the Kp=-1 doesn't mean it actually
//		happened. These function query the internal state of the PID. 
//		They're here for display purposes. These are the functions
//		the PID front-end uses for example. 
// Arguments:   None
/////////////////////////////////////////////////////////////////////////////    
function Pid::GetKp() { return dispKp; }
function Pid::GetKi() { return dispKi; }
function Pid::GetKd() { return dispKd; }
function Pid::GetMode() { return inAuto ? AUTOMATIC : MANUAL; }
function Pid::GetDirection() { return controllerDirection; }


