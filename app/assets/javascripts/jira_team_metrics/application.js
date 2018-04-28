// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery
//= require semantic_ui/semantic_ui
//= require pickadate/picker
//= require pickadate/picker.date
//= require handlebars.runtime
//= require lodash
//= require_tree ./templates
//= require_tree .

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

$(function() {
  $('.menu .item').tab();
  $('.ui.accordion').accordion();
})

$(function() {
  //$('.datepicker').on('change', function(){
  //  $('#pickadate-container').find('.picker__close').click();
  //});

  $(document).on('change', 'form.flag-outlier input', function(event) {
    var $form = $(event.target).closest('form.flag-outlier');
    var url = $form.attr('action');
    var payload = $form.serialize();
    $.ajax({
      url: url,
      type: 'PUT',
      data: payload,
      success: function() {
        location.reload();
      }
    })
  });
});