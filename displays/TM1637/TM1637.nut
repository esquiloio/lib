class TM1637
{
    _clk = null;
    _data = null;
    _brightness = 2;
}

function TM1637::constructor(clk, data)
{
	_clk = clk;
    _data = data;
    
    _clk.output();
    _data.output();
}

function TM1637::bitDelay()
{
	udelay(50);
}

function TM1637::writeByte(value)
{
    for(local i = 0; i < 8; i++) {
        _clk.low();
        if (value & 0x01)
            _data.high();
        else
            _data.low();
        value = (value >> 1);
        _clk.high();
    }
    
    _clk.low();
    _data.high();
    _clk.high();
    _data.input();
    
  	bitDelay();
  	local ack = _data.read();
    if (_data.islow()) {
        _data.output();
        _data.low();
    }
    bitDelay();
    _data.output();
    bitDelay();
  
  	return ack;
}

function TM1637::start()
{
    _clk.high();
    _data.high();
    _data.low();
    _clk.low();
}

function TM1637::stop()
{
    _clk.low();
    _data.low();
    _clk.high();
    _data.high();
}

const TM1367_ADDR_AUTO = 0x40;
const TM1367_ADDR_FIXED = 0x44;
const TM1367_STARTADDR = 0xc0;
    
function TM1637::display(grid, seg)
{
    start();
    writeByte(0x44);
    stop();
    start();
    writeByte(0xc0 | grid);
    writeByte(seg);
    stop();
    start();
    writeByte(0x88 + _brightness);
    stop();
}

function TM1637::brightness(value)
{
	_brightness = value;   
}
