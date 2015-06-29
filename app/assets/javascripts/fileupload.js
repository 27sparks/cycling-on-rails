$(document).ready(function() {
    var fileChooser = document.getElementById('fileChooser');
    var files_array = []
    var errors_array = []

    function parseTextAsXml(text) {
        var parser = new DOMParser(),
            xmlDom = parser.parseFromString(text, "text/xml");

        //now, extract items from xmlDom and assign to appropriate text input fields
    }
    function update_view(files_number) {
        $('.number_of_files')[0].innerHTML = files_number
    }
    function handle_file_upload() {
        update_view(files_array.length)
        var reader = new FileReader();
        waitForTextReadComplete(reader);
        reader.readAsText(files_array.shift());
    }

    function sendXmlToApp(text) {
        $('.blurdiv').show()

        $.ajax({
            url: "/activities",
            data: text,
            type: 'POST',
            contentType: "text/xml",
            dataType: "xml",
            success: function(){
                if (files_array.length > 0) {
                    handle_file_upload()
                } else {
                    window.location.reload()
                }
            },
            error: function (xhr, ajaxOptions, thrownError) {
                console.log(xhr.status);
                console.log(thrownError);
                alert('Error uploading file!');
                if (files_array.length > 0) {
                    handle_file_upload()
                } else {
                    alert('Error uploading file!');
                    window.location.reload()
                }
            }
        });
    }

    function waitForTextReadComplete(reader) {
        reader.onloadend = function (event) {
            var text = event.target.result;
            sendXmlToApp(text);
        }
    }

    function handleFileSelection() {
        var files = fileChooser.files;
        for ( i=0; i < files.length; i++) {
            files_array.push(files[i])
        }
        handle_file_upload()
    }

    fileChooser.addEventListener('change', handleFileSelection, false);
});