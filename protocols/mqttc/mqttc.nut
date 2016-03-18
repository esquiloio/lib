/////////////////////////////////////////////////////////////////////////////
// MQTTC - Simple MQTT client class
//
// Note: Only supports QoS 0 and does not support wills
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
//
// Public API:
// * constructor(client, publish)
// * receive()
// * connect(hostname, port, options)
// * isconnected()
// * disconnect()
// * subscribe(filter)
// * unsubscribe(filter)
// * publish(topic, payload)
//
// Example usage:
//
// mqtt <- MQTTC("MyEsquilo", function(topic, payload) {
//     local value = payload.readstr(100);
//     print(topic + " : " + value + "\n");
// });
// 
// try {
//     mqtt.connect("test.mosquitto.org", 1883, null);
//     mqtt.subscribe("temp/random");
// 
//     local payload = blob();
//     payload.writestr("30");
//     mqtt.publish("temp/random", payload);
//     
//     while (true) {
//         mqtt.receive();
//         delay(10);
//     }
// }
// catch (e) {
//     print("MQTT Exception: " + e + "\n");
//     mqtt.disconnect();
//     mqtt = null;
// }

require(["Socket", "Timer"]);
        
class MQTTC
{
    // Client ID
    _clientId = null;
    
    // Published message callback function
    _published = null;
    
	// Response timeout in milliseconds    
    _timeout = 3000;
    
    // Network socket
    _socket = null;
    
    // Keppalive timer
    _timer = null;
    
    // Packet ID
    _packetId = 0;
    
    // State for receive process
    _rxState = 0;
    _rxLength = 0;
    _rxType = 0;
    _rxFlags = 0;
    _rxPacket = null;
    _rxResponse = 0;
}

// Receive states
enum RX_STATE {
    TYPE,
    LENGTH,
    PAYLOAD,
};

// Protocol Level (3.1.1)
const PROTOCOL_LEVEL = 4;

// Packet Types
const CONNECT		= 1;
const CONNACK		= 2;
const PUBLISH		= 3;
const PUBACK		= 4;
const PUBREC		= 5;
const PUBREL		= 6;
const PUBCOMP		= 7;
const SUBSCRIBE		= 8;
const SUBACK		= 9;
const UNSUBSCRIBE	= 10;
const UNSUBACK		= 11;
const PINGREQ		= 12;
const PINGRESP		= 13;
const DISCONNECT	= 14;

// Connect Flags
const CONNECT_CLEAN		= 0x02;
const CONNECT_PASSWORD	= 0x40;
const CONNECT_USERNAME	= 0x80;

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a MQTT client.
// Arguments:   clientId  - A string with the client ID
//              published - Callback function for received publish messages
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTC::constructor(clientId, published)
{
    _clientId = clientId;
    _published = published;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    receive
// Description: Message receive loop.  Should be called regularly from the
//              main loop to process incoming MQTT messages.
// Arguments:   None
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTC::receive()
{
    while (true) {
        local available = _socket.available();

        switch (_rxState) {
            case RX_STATE.TYPE: {
                // Make sure we have a byte
                if (available <= 0)
                    return;

                // Decode the type and flags and move to the next state
                local rxByte = _socket.read();
                _rxType = rxByte >> 4;
                _rxFlags = rxByte & 0xf;
                _rxLength = 0;
                _rxState = RX_STATE.LENGTH;
                break;
            }
            case RX_STATE.LENGTH: {
                // Make sure we have a byte
                if (available <= 0)
                    return;

                // Decode the length
                local rxByte = _socket.read();
                _rxLength = (_rxLength << 7) | (rxByte & 0x7f);
                
                // Move to the next state if this is the last byte
                if (!(rxByte & 0x80)) {
                    _rxState = RX_STATE.PAYLOAD;
                }
                break;
            }
            case RX_STATE.PAYLOAD: {
                // Make sure we have the complete payload
                if (available < _rxLength)
                    return;

                // Read the payload from the socket
                _rxPacket = MQTTPacket();
                _rxPacket.setBlob(_socket.readblob(_rxLength));

                _rxState = RX_STATE.TYPE;
                
                // We only support QoS 0
                if ((_rxFlags & 0x6) != 0)
                	throw("unsupported qos");

                if (_rxType == PUBLISH) {
                    // Decode the topic and application data
                    local topic = _rxPacket.decString();
                    local length = _rxPacket.decLength();
                    local payload = _rxPacket.decBlob(length);
                    
                    // Execute the callback function
                    _published(topic, payload);
                    return;
                }
                else if (_rxType == _rxResponse) {
                    // A method is blocking on this response
                    _rxResponse = 0;
                    return;
                }
                else {
                    throw("unexpected packet");
                }

	            break;
            }
        }
    }
}

/////////////////////////////////////////////////////////////////////////////
// Function:    connect
// Description: Connect to an MQTT server
// Arguments:   hostname - the host name or IP address of the MQTT server
//              port - the TCP port to connect to
//              options - table of extra options
//                  * timeout - response timeout for MQTT messages
//                  * keepalive - keepalive interval in seconds
//                  * username - username string to pass to server
//                  * password - password string to pass to server
//                  * clean - boolean indicating to start a clean session
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTC::connect(hostname, port, options)
{
    local packet;
    local keepalive;
    local username;
    local password;
    local clean;
    local flags;
    
    // Disconnect from any active session
    disconnect();
    
    // Parse the options table
    if ("timeout" in options)
        _timeout = options.timeout;
    else
        _timeout = 3000;
    
    if ("keepalive" in options)
        keepalive = options.keepalive;
    else
        keepalive = 60;
    
    if ("username" in options)
        username = options.username;
    
    if ("password" in options)
        password = options.password;

    if ("clean" in options)
        clean = options.clean;
    else
        clean = true;
    
    // Connect to the server
    _socket = Socket();
    _socket.connect(hostname, port);
    
    // Create a CONNECT packet
    packet = MQTTPacket();
    packet.encHeader(CONNECT, 0);
    packet.encString("MQTT");
    packet.encByte(PROTOCOL_LEVEL);
    
    // Create flags from the options
    flags = 0;
    if (clean)
    	flags = flags | CONNECT_CLEAN;
    if (username)
        flags = flags | CONNECT_USERNAME;
    if (password)
        flags = flags | CONNECT_PASSWORD;
    packet.encByte(flags);
    
    // Encode the keepalive and client ID
    packet.encWord(10 * keepalive);
    packet.encString(_clientId);
    
    // Encode username and password if in the options
    if (username)
    	packet.encString(username);
    if (password) {
        packet.encWord(password.len());
        packet.encBlob(password);
    }
    
    // Send the CONNECT to the server
    _socket.writeblob(packet.getBlob());

    // Wait for the server to respond with a CONNACK
    _waitForResponse(CONNACK);
        
    // Decode the CONNACK
    if (_rxLength != 2)
        throw("invalid length");
    
    _rxPacket.decByte();
    switch (_rxPacket.decByte()) {
        case 0:
        	break;
        case 1:
        	throw("unacceptable protocol version");
        case 2:
        	throw("identifier rejected");
        case 3:
        	throw("server unavailable");
        case 4:
        	throw("bad user name or password");
        case 5:
        	throw("not authorized");
    	default:
        	throw("reserved response");
    }
    
    // Start the keepalive timer
    _timer = Timer(_ping.bindenv(this));
    _timer.interval(keepalive * 1000);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    isconnected
// Description: Test if MQTT client is connected to server
// Arguments:   None
// Return:      true if socket is connected and false otherwise
/////////////////////////////////////////////////////////////////////////////
function MQTTC::isconnected()
{
    return (_socket && _socket.isconnected());
}

/////////////////////////////////////////////////////////////////////////////
// Function:    disconnect
// Description: Send MQTT disconnect message and close the socket
// Arguments:   None
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTC::disconnect()
{
    if (_socket) {
        if (_socket.isconnected()) {
            local packet;
            packet = MQTTPacket();
            packet.encHeader(DISCONNECT, 0);
            _socket.writeblob(packet.getBlob());
        }
        _timer = null;
        _socket = null;
    }
}

/////////////////////////////////////////////////////////////////////////////
// Function:    subscribe
// Description: Send MQTT subscribe message to subscribe to topics
// Arguments:   filter - MQTT topic filter string
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTC::subscribe(filter)
{
    local packet;
    
    packet = MQTTPacket();
    packet.encHeader(SUBSCRIBE, 0x2);
   	packet.encWord(++_packetId);
    packet.encString(filter);
	packet.encByte(0);
                     
    _socket.writeblob(packet.getBlob());
    
    _waitForResponse(SUBACK);

    local id = _rxPacket.decWord();
    if (id != _packetId)
        throw("packet ID mismatch");

    _rxPacket = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    unsubscribe
// Description: Send MQTT unsubscribe message to remove topic subscriptions
// Arguments:   filter - MQTT topic filter string
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTC::unsubscribe(filter)
{
    local packet;
    
    packet = MQTTPacket();
    packet.encHeader(UNSUBSCRIBE, 0);
   	packet.encWord(++_packetId);
    packet.encString(filter);
                     
    _socket.writeblob(packet.getBlob());
    
    _waitForResponse(UNSUBACK);

    if (_rxPacket.decWord() != _packetId)
        throw("packet ID mismatch");

    _rxPacket = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    publish
// Description: Send an MQTT publish message
// Arguments:   topic - text string of the MQTT topic to publish to
//              payload - blob containing the payload for the publish
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTC::publish(topic, payload)
{
    local packet;
    
    packet = MQTTPacket();
    packet.encHeader(PUBLISH, 0);
    packet.encString(topic);
    packet.encBlob(payload);
    
    _socket.writeblob(packet.getBlob());
}

/////////////////////////////////////////////////////////////////////////////
//
// Private methods
//
/////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////
// Function:    _waitForResponse
// Description: Blocks waiting for a response message unless timeout expires
// Arguments:   type - the MQTT message type to wait for
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTC::_waitForResponse(type)
{
    local time = 0;
    
    _rxResponse = type;
    
    while (true) {
        receive();
        if (_rxResponse != type)
            break;
        
        if (time >= _timeout)
            throw("response timeout");
        
        delay(10);
        time += 10;
    }
}

/////////////////////////////////////////////////////////////////////////////
// Function:    _ping
// Description: Sends an MQTT ping to the server
// Arguments:   None
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTC::_ping()
{
    local packet = MQTTPacket();
    packet.encHeader(PINGREQ, 0);
    _socket.writeblob(packet.getBlob());
    _waitForResponse(PINGRESP);
}


/////////////////////////////////////////////////////////////////////////////
// 
// MQTTPacket class - encapsulates MQTT packet encoding and decoding methods
//
/////////////////////////////////////////////////////////////////////////////
class MQTTPacket
{
    _packet = null;
    _header = 0;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    encHeader
// Description: Encode the packet header
// Arguments:   type - MQTT packet type
//              flags - 4-bit flags field
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::encHeader(type, flags)
{
    _packet = blob(64);
    _header = ((type & 0xf) << 4) | (flags & 0xf);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    encString
// Description: encode a string in the packet
// Arguments:   string - string to encode
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::encString(string)
{
    encWord(string.len());
    _packet.writestr(string);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    encBlob
// Description: encode a binary blob in the packet
// Arguments:   buffer - the binary blob to encode
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::encBlob(buffer)
{
    _packet.writeblob(buffer);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    encByte
// Description: encode a single byte in the packet
// Arguments:   byte - the byte value to encode
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::encByte(byte)
{
    _packet.write(byte);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    encWord
// Description: encode a 16-bit word in the packet
// Arguments:   word - the 16-bit word to encode
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::encWord(word)
{
    _packet.writen(swap2(word), 'w');
}

/////////////////////////////////////////////////////////////////////////////
// Function:    getBlob
// Description: Return the packet as a binary blob
// Arguments:   None
// Return:      The packet as a binary blob
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::getBlob()
{
    local length = _packet.tell();
    local buffer = blob(2);
    local byte;
    local len;
    
    buffer.write(_header);
    
    len = length;
    do {
    	byte = len & 0x7f;
      	len = len >> 7;
        
      	if ( len > 0 )
        	byte = byte | 0x80;
        
		buffer.write(byte);
    } while (len > 0)
            
    _packet.resize(length);
	buffer.writeblob(_packet);
    
    return buffer;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    decByte
// Description: decode a byte in the packet
// Arguments:   None
// Return:      the decoded byte
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::decByte()
{
    return _packet.read();
}

/////////////////////////////////////////////////////////////////////////////
// Function:    decWord
// Description: decode a 16-bit word in the packet
// Arguments:   None
// Return:      the decoded 16-bit word
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::decWord()
{
    local word = swap2(_packet.readn('w'));
    return word;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    decString
// Description: decode a string in the packet
// Arguments:   None
// Return:      the decoded string
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::decString()
{
    local length = decWord();
    return _packet.readstr(length);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    decBlob
// Description: decode a binary blob in the packet
// Arguments:   length - number of bytes in the blob
// Return:      the binary blob
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::decBlob(length)
{
    return _packet.readblob(length);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    decLength
// Description: return the packet length left to decode
// Arguments:   None
// Return:      the length left to decode
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::decLength()
{
    return (_packet.len() - _packet.tell());
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setBlob
// Description: set the packet to a binary blob for decoding
// Arguments:   buffer - the binary blob to decode
// Return:      None
/////////////////////////////////////////////////////////////////////////////
function MQTTPacket::setBlob(buffer)
{
    _packet = buffer;
}
