// Grove Buzzer Demo
//
// See README.md for more information.
//
// This work is released under the Creative Commons Zero (CC0) license.
// See http://creativecommons.org/publicdomain/zero/1.0/
$(document).ready(function() {
    var SONG_LENGTH = 18;
    // load the notes template file, then render it with data
    var html = new EJS({url: 'notes.ejs'}).render({length:SONG_LENGTH});
    $('#notes').append(html);

    var songs = {
        twinkleTwinkleLittleStar: {
            tempo: 300,
            notes: [
                {note: 'c', beats: 1},
                {note: 'c', beats: 1},
                {note: 'g', beats: 1},
                {note: 'g', beats: 1},
                {note: 'a', beats: 1},
                {note: 'a', beats: 1},
                {note: 'g', beats: 2},
                {note: 'f', beats: 1},
                {note: 'f', beats: 1},
                {note: 'e', beats: 1},
                {note: 'e', beats: 1},
                {note: 'd', beats: 1},
                {note: 'd', beats: 1},
                {note: 'c', beats: 2},
                {note: ' ', beats: 1},
                {note: ' ', beats: 1},
                {note: ' ', beats: 1},
                {note: ' ', beats: 1}
            ]
        },
        threeBlindMice: {
            tempo: 250,
            notes: [
                {note: 'e', beats: 1},
                {note: 'd', beats: 1},
                {note: 'c', beats: 2},
                {note: ' ', beats: 1},
                {note: 'e', beats: 1},
                {note: 'd', beats: 1},
                {note: 'c', beats: 2},
                {note: ' ', beats: 1},
                {note: 'g', beats: 1},
                {note: 'f', beats: 1},
                {note: 'f', beats: 1},
                {note: 'e', beats: 2},
                {note: ' ', beats: 1},
                {note: 'g', beats: 1},
                {note: 'f', beats: 1},
                {note: 'f', beats: 1},
                {note: 'e', beats: 2},
                {note: ' ', beats: 1}
            ]
        }
    };

    function setSong(value) {
        $('#song').val(value);
        var song = songs[value];
        $('#tempo').val(song.tempo);
        for (var i=0; i < song.notes.length; i++) {
            $('#note-' + i).val(song.notes[i].note);
            $('#beats-' + i).val(song.notes[i].beats);
        }
    }

    $('#song').on('change', function() {
        console.log(this.value, 'selected');
        setSong(this.value);
    });

    setSong('twinkleTwinkleLittleStar');

	$('#play-button').on('click', function(event) {
        var song = {
            tempo:  $('#tempo').val(),
            notes: []
        };
        song.tempo = $('#tempo').val();
        for (var i=0; i < SONG_LENGTH; i++)
            song.notes.push({note: $('#note-'+i).val(), beats: parseInt($('#beats-'+i).val())})
        erpc("play", song);
    });

    demoInit('buzzer');
});