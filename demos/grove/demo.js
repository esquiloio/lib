function demoInit(name) {
    // load the run template file, then render it, and add it to the doc body
    var html = new EJS({url: '../demo.ejs'}).render({nut: name + '.nut'});
    $( "body" ).append(html);

    rpc = new Rpc('/rpc');
    $('#run-button').on('click', function (event) {
        rpc.sqKill();
        rpc.bpClear();
        rpc.sqReset();
        rpc.sqRun('sd:/lib/demos/grove/' + name + '/' + name + '.nut', function () {
                $('#run-modal').modal();
            },
            function () {
                $('#run-modal-fail').modal();
            });
    });

    $('#run-modal').on('shown.bs.modal', function () {
        $('#run-modal .ok-button').focus()
    });

    $('#run-modal-fail').on('shown.bs.modal', function () {
        $('#run-modal-fail .ok-button').focus()
    });
}