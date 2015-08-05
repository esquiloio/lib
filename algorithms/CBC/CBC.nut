/////////////////////////////////////////////////////////////////////////////
// Cipher block chaining (CBC) block cipher mode
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
/////////////////////////////////////////////////////////////////////////////
class CBC
{
    _cipher = null;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    constructor
// Description: Create a CBC instance
// Arguments:	cipher - cipher instance to use
/////////////////////////////////////////////////////////////////////////////
function CBC::constructor(cipher)
{
    _cipher = cipher;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    setCipher
// Description: Set the cipher
// Arguments:	cipher - cipher instance to use
/////////////////////////////////////////////////////////////////////////////
function CBC::setCipher(cipher)
{
    _cipher = cipher;
}

/////////////////////////////////////////////////////////////////////////////
// Function:    encrypt
// Description: Encrypt plain text using AES CBC
// Arguments:	input - input plain text data as a blob
//              iv - initialization vector as a blob
//              output - output cipher text as a blob
/////////////////////////////////////////////////////////////////////////////
function CBC::encrypt(input, iv, output)
{
    local chain = iv;
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
        
		// XOR the input block with the chain block
        for (local i = 0; i < blksize; i++)
            inblk[i] = inblk[i] ^ chain[i];
        
        // Encrypt the block
        _cipher.encrypt(inblk, outblk);
        
        // Write the ciphertext out
        output.writeblob(outblk);
        
        // The next chain block is the output block
        chain = outblk;
    }
}

/////////////////////////////////////////////////////////////////////////////
// Function:    decrypt
// Description: Decrypt cipher text using AES CBC
// Arguments:	input - input cipher text data as a blob
//              iv - initialization vector as a blob
//              output - output plain text as a blob
/////////////////////////////////////////////////////////////////////////////
function CBC::decrypt(input, iv, output)
{
    local chain = iv;
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
        
        // XOR the plaintext block with the chain block
        for (local i = 0; i < blksize; i++)
            outblk[i] = outblk[i] ^ chain[i];
        
        // Write the plaintext out
        output.writeblob(outblk);
        
        // The next chain block is the input block
        chain = inblk;
    }
}

