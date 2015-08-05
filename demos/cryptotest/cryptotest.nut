// Crypto Test Demo
//
// See readme.txt for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

require("Crypto");

dofile("sd:/lib/algorithms/hmac/hmac.nut");
dofile("sd:/lib/algorithms/ecb/ecb.nut");
dofile("sd:/lib/algorithms/cbc/cbc.nut");
dofile("sd:/lib/algorithms/ctr/ctr.nut");

function blobdump(msg, b)
{
    print(msg + ": ");
    for (local i = 0; i < b.len(); i++)
        print(format("%02x", b[i]));
    print("\n");
}

function blobhex(str)
{
    local b = blob();
    
    for (local i = 0; i < str.len(); i += 2)
        b.write(parseint(str.slice(i, i + 2), 16));
    
	return b;
}

function blobstr(str)
{
    local b = blob();
    
    b.writestr(str);

    return b;
}

function blobequal(a, b)
{
    for (local i = 0; i < a.len(); i++) {
        if (a[i] != b[i])
        	return false;
    }
	return true;    
}

function testcheck(a, b)
{
    if (blobequal(a, b))
	    print("Test passed\n\n");
    else
        print("*** TEST FAILED ***\n\n");
}

function ecbtest(name)
{
    print("ECB-" + name + " Test\n");
    mode <- ECB(cipher);
    mode.encrypt(test, output);
    blobdump("Encrypt", output);
    mode.decrypt(output, verify);
    blobdump("Decrypt", verify);
    testcheck(test, verify);
}

function cbctest(name)
{
    print("CBC-" + name + " Test\n");
    mode <- CBC(cipher);
    mode.encrypt(test, iv, output);
    blobdump("Encrypt", output);
    mode.decrypt(output, iv, verify);
    blobdump("Decrypt", verify);
    testcheck(test, verify);
}

function ctrtest(name)
{
    print("CTR-" + name + " Test\n");
    mode <- CTR(cipher);
    mode.encrypt(test, nonce, output);
    blobdump("Encrypt", output);
    mode.decrypt(output, nonce, verify);
    blobdump("Decrypt", verify);
    testcheck(test, verify);
}

function ciphertest(name)
{
    output <- blob();
    verify <- blob();
    ecbtest(name);
    cbctest(name);
    ctrtest(name);
}

/////////////////////////////////////////////////////////////////////////////
//
// Hash tests
//
/////////////////////////////////////////////////////////////////////////////

// Hash test vector
test <- blobstr("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq");

// MD5 test
hash <- md5hash(test);
blobdump("MD5", hash);
testcheck(hash, blobhex("8215EF0796A20BCAAAE116D3876C664A"));

// SHA1 test
hash <- sha1hash(test);
blobdump("SHA1", hash);
testcheck(hash, blobhex("84983e441c3bd26ebaae4aa1f95129e5e54670f1"));

// SHA256 test
hash <- sha256hash(test);
blobdump("SHA256", hash);
testcheck(hash, blobhex("248D6A61D20638B8E5C026930C3E6039A33CE45964FF2167F6ECEDD419DB06C1"));

/////////////////////////////////////////////////////////////////////////////
//
// HMAC tests
//
/////////////////////////////////////////////////////////////////////////////

// HMAC test vector
test <- blobstr("The quick brown fox jumps over the lazy dog");

// HMAC key
key <- blobstr("key");

// MD5 HMAC test
hmac <- HMAC(md5hash).generate(key, test);
blobdump("MD5 HMAC", hmac);
testcheck(hmac, blobhex("80070713463e7749b90c2dc24911e275"));

// SHA1 HMAC test
hmac <- HMAC(sha1hash).generate(key, test);
blobdump("SHA1 HMAC", hmac);
testcheck(hmac, blobhex("de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9"));

// SHA256 HMAC test
hmac <- HMAC(sha256hash).generate(key, test);
blobdump("SHA256 HMAC", hmac);
testcheck(hmac, blobhex("f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8"));

/////////////////////////////////////////////////////////////////////////////
//
// AES tests
//
/////////////////////////////////////////////////////////////////////////////

// Cipher test vector
test <- blobhex("6bc1bee22e409f96e93d7e117393172a" +
                "ae2d8a571e03ac9c9eb76fac45af8e51" +
                "30c81c46a35ce411e5fbc1191a0a52ef" +
                "f69f2445df4f9b17ad2b417be66c3710");

// IV for CBC mode
iv <- blobhex("000102030405060708090A0B0C0D0E0F");

// nonce for CTR mode
nonce <- blobhex("f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff");

// AES-128 tests
cipher <- AESCipher(blobhex("2b7e151628aed2a6abf7158809cf4f3c"));
ciphertest("AES128");

// AES-192 tests
cipher <- AESCipher(blobhex("8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b"));
ciphertest("AES192");

// AES-256 tests
cipher <- AESCipher(blobhex("603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"));
ciphertest("AES256");

/////////////////////////////////////////////////////////////////////////////
//
// 3DES tests
//
/////////////////////////////////////////////////////////////////////////////

// Cipher test vector
test <- blobhex("84401f78fe6c10876d8ea23094ea5309");

// IV for CBC mode
iv <- blobhex("3d1de3cc132e3b65");

// nonce for CTR mode
nonce <- blobhex("3d1de3cc132e3b65");

// 3DES tests
cipher <- TDESCipher(blobhex("37ae5ebf46dff2dc0754b94f31cbb3855e7fd36dc870bfae"));
ciphertest("3DES");

