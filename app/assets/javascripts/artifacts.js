// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(function() {
    $('.artifacts .delete').each(function (index, item) {
        $(item).click(function (event) {
            if (! confirm("Are you sure to delete this item?:\n" + $(item).data('artifact-version'))) {
                event.preventDefault();
                event.stopImmediatePropagation()
            }
        });
    });
});