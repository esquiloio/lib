// Buzzer Demo for Grove Starter Kit for Arduino
//
// Ported from:
//   https://github.com/Seeed-Studio/Sketchbook_Starter_Kit_V2.0
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/

//
// Adapted from the Arduino project:
//
// Melody
// (cleft) 2005 D. Cuartielles for K3
//
// This example uses a piezo speaker to play melodies.  It sends
// a square wave of the appropriate frequency to the piezo, generating
// the corresponding tone.
//
// The calculation of the tones is made following the mathematical
// operation:
//
//       timeHigh = period / 2 = 1 / (2 * toneFrequency)
//
// where the different tones are described as in the table:
//
// note  frequency  period  timeHigh
//  c     261 Hz     3830    1915
//  d     294 Hz     3400    1700
//  e     329 Hz     3038    1519
//  f     349 Hz     2864    1432
//  g     392 Hz     2550    1275
//  a     440 Hz     2272    1136
//  b     493 Hz     2028    1014
//  C     523 Hz     1912    956
//
// http://www.arduino.cc/en/Tutorial/Melody
//

require("GPIO");

// Grove Buzzer connect to D3
const PIN_BUZZER = 3;

// Configure the buzzer's pin for output
speaker <- GPIO(PIN_BUZZER);
speaker.output();

tones <- { c=1915, d=1700, e=1519, f=1432, g=1275, a=1136, b=1014, C=956 };

twinkleTwinkleLittleStar <- {
    tempo=300,
    notes=[
        {note='c', beats=1},
        {note='c', beats=1},
        {note='g', beats=1},
        {note='g', beats=1},
        {note='a', beats=1},
        {note='a', beats=1},
        {note='g', beats=2},
        {note='f', beats=1},
        {note='f', beats=1},
        {note='e', beats=1},
        {note='e', beats=1},
        {note='d', beats=1},
        {note='d', beats=1},
        {note='c', beats=2},
        {note=' ', beats=1}
    ]
};

function playTone(tone, duration)
{
    for (local i = 0; i < duration * 1000; i += tone * 2) {
        speaker.high();
        udelay(tone);
        speaker.low();
        udelay(tone);
    }
}

function playNote(note, duration)
{
    // play the tone corresponding to the note name
    playTone(tones[note.tochar()], duration);
}

function playSong(song)
{
    for (local i=0; i < song.notes.len(); i++) {
        print("note: " + song.notes[i].note.tochar() + " beats: " + song.notes[i].beats + "\n");
        if (song.notes[i].note == ' ')
            delay(song.notes[i].beats * song.tempo); // rest
        else
            playNote(song.notes[i].note, song.notes[i].beats * song.tempo);

        // pause between notes
        delay(song.tempo / 2);
    }
}

//playSong(twinkleTwinkleLittleStar);

// ERPC
function play(song)
{
    song.tempo = song.tempo.tointeger();
    for (local i=0; i < song.notes.len(); i++)
        song.notes[i].note = song.notes[i].note[0];
    playSong(song);
}

