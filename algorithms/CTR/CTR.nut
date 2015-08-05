/////////////////////////////////////////////////////////////////////////////
// Counter (CTR) block cipher mode
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
class CTR
{
    _cipher = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a AES CTR instance
// Arguments:	cipher - cipher instance to use
/////////////////////////////////////////////////////////////////////////////
function CTR::constructor(cipher)
{
    _cipher = cipher;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setCipher
// Description: Set the cipher
// Arguments:	cipher - cipher instance to use
/////////////////////////////////////////////////////////////////////////////
function CTR::setCipher(cipher)
{
    _cipher = cipher;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    encrypt
// Description: Encrypt plain text using AES CTR
// Arguments:	input - input plain text data as a blob
//              nonce - nonce as a blob
//              output - output cipher text as a blob
/////////////////////////////////////////////////////////////////////////////
function CTR::encrypt(input, nonce, output)
{
    _crypt(input, nonce, output);
}

/////////////////////////////////////////////////////////////////////////////
// Function:    decrypt
// Description: Decrypt cipher text using AES CTR
// Arguments:	input - input cipher text as a blob
//              nonce - nonce as a blob
//              output - output plain text data as a blob
/////////////////////////////////////////////////////////////////////////////
function CTR::decrypt(input, nonce, output)
{
    _crypt(input, nonce, output);
}

/////////////////////////////////////////////////////////////////////////////
// Private functions
/////////////////////////////////////////////////////////////////////////////

function CTR::_increment(counter)
{
    for (local i = counter.len() - 1; i >= 0; i--) {
        counter[i]++;
        if (counter[i] != 0)
            break;
    }
}
    
function CTR::_crypt(input, nonce, output)
{
    local counter = clone nonce;
    local inblk;
    local blksize = _cipher.blocksize();
    local outblk = blob(blksize);
    
    // Start at the beginning
    input.seek(0);
    output.seek(0);
    
    // Loop through all blocks
    while (!input.eos()) {
        
        // Read a block and zero pad if necessary
        inblk = input.readblob(blksize);
        if (inblk.len() < blksize) {
            inblk.seek(0, 'e');
            inblk.fill(0, blksize - inblk.len());
        }
        
        // Encrypt the block
        _cipher.encrypt(counter, outblk);
        
        // XOR the cipher text with the input
        for (local i = 0; i < blksize; i++)
            outblk[i] = outblk[i] ^ inblk[i];
        
        // Write the result out
        output.writeblob(outblk);
        
        // Increment the counter
		_increment(counter);
    }
}

