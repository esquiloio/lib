/////////////////////////////////////////////////////////////////////////////
// Electronic codebook (ECB) block cipher mode
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
class ECB
{
    _cipher = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a AES ECB instance
// Arguments:	cipher - cipher instance to use
/////////////////////////////////////////////////////////////////////////////
function ECB::constructor(cipher)
{
    _cipher = cipher;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setCipher
// Description: Set the cipher
// Arguments:	cipher - cipher instance to use
/////////////////////////////////////////////////////////////////////////////
function ECB::setCipher(cipher)
{
    _cipher = cipher;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    encrypt
// Description: Encrypt plain text using AES ECB
// Arguments:	input - input plain text data as a blob
//              output - output cipher text as a blob
/////////////////////////////////////////////////////////////////////////////
function ECB::encrypt(input, output)
{
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
        _cipher.encrypt(inblk, outblk);
        
        // Write the block out
        output.writeblob(outblk);
    }
}

/////////////////////////////////////////////////////////////////////////////
// Function:    decrypt
// Description: Decrypt cipher text using AES ECB
// Arguments:	input - input cipher text data as a blob
//              output - output plain text as a blob
/////////////////////////////////////////////////////////////////////////////
function ECB::decrypt(input, output)
{
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
        
        // Decrypt the block
        _cipher.decrypt(inblk, outblk);
        
        // Write the block out
        output.writeblob(outblk);
    }
}

