/////////////////////////////////////////////////////////////////////////////
// Keyed-hash message authentication code (HMAC)
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
class HMAC
{
    _hash = null;
    _blocksize = 64;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a AES ECB instance
// Arguments:	hash - hash function to use
/////////////////////////////////////////////////////////////////////////////
function HMAC::constructor(hash)
{
    _hash = hash;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setHash
// Description: Set the hash function
// Arguments:	hash - hash function to use
/////////////////////////////////////////////////////////////////////////////
function HMAC::setHash(hash)
{
    _hash = hash;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setBlockSize
// Description: Set the block size
// Arguments:	blocksize - block size to use
/////////////////////////////////////////////////////////////////////////////
function HMAC::setBlockSize(blocksize)
{
    _blocksize = blocksize;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    generate
// Description: Generate an HMAC for a message with the given key
// Arguments:	key - key to use as a blob or string
//              message - the message to generate the HMAC for as a blob
/////////////////////////////////////////////////////////////////////////////
function HMAC::generate(key, message)
{
    local i_pad = blob();
    local o_pad = blob();
    local sum;
    
    // Generate the pad blobs
    i_pad.fill(0x36, _blocksize);
    o_pad.fill(0x5c, _blocksize);
    
    // Hash the key if it is too big
    if (key.len() > _blocksize)
        key = _hash(key);
    
    // XOR the pads with the key
    for (local i = 0; i < key.len(); i++) {
        i_pad[i] = i_pad[i] ^ key[i];
        o_pad[i] = o_pad[i] ^ key[i];
    }

    // Generate the first pass hash
    i_pad.writeblob(message);
    sum = _hash(i_pad);
    
    // Generate the second pass hash
    o_pad.writeblob(sum);
    sum = _hash(o_pad);
    
    return sum;
}

