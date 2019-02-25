$.fn.setNow = function (onlyBlank) {
    var now = new Date($.now());
    
    var year = now.getFullYear();
    
    var month = (now.getMonth() + 1).toString().length === 1 ? '0' + (now.getMonth() + 1).toString() : now.getMonth() + 1;
    var date = now.getDate().toString().length === 1 ? '0'         + (now.getDate()).toString()      : now.getDate();
    var hours = now.getHours().toString().length === 1 ? '0'       + now.getHours().toString()       : now.getHours();
    var minutes = now.getMinutes().toString().length === 1 ? '0'   + now.getMinutes().toString()     : now.getMinutes();
    
    var formattedDateTime = year + '-' + month + '-' + date + 'T' + hours + ':' + minutes;
    
    if ( onlyBlank === true && $(this).val() ) {
        return this;
    }
    
    $(this).val(formattedDateTime);
    
    return this;
}

$(document).ready ( function() {
    $('input[type="datetime-local"]').setNow();
});

$('#signOutModal').on('show.bs.modal', function (event) {
    var button = $(event.relatedTarget) // Button that triggered the modal
    var tutee = button.data('tutee') // Extract info from data-* attributes
    var modal = $(this)
    modal.find('.modal-body').text('Sign out ' + tutee + '?')
    modal.find('.modal-footer input').val(tutee)
});
