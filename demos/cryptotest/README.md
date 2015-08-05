Crypto Test Demo
================
The crypto test demo functions as both a demo of using the various cryptography
functions available in Esquilo and a validation of their correctness.  Test
vectors were taken from NIST and other sources.  All of the cryptography
functions are hardware accelerated inside the Kinetis processor on Esquilo.
The demo tests the following crypto algorithms:
 * MD5 Digest
 * SHA1 Digest
 * SHA256 Digest
 * HMAC-MD5
 * HMAC-SHA1
 * HMAC-SHA256
 * ECB-AES128
 * ECB-AES192
 * ECB-AES256
 * ECB-3DES
 * CBC-AES128
 * CBC-AES192
 * CBC-AES256
 * CBC-3DES
 * CTR-AES128
 * CTR-AES192
 * CTR-AES256
 * CTR-3DES

### Run the Squirrel Code

Bring up the Web IDE from your Esquilo, and run the "cryptotest.nut" file.
The results of the crypto tests are displayed in the console window.  If any
test fails, you will see a TEST FAILED message.

# License

This work is released under the Creative Commons Zero (CC0) license.
See http://creativecommons.org/publicdomain/zero/1.0/
