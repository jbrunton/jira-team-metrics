function alertModal(opts) {
  var context = {
    title: opts.title,
    message: opts.message
  };

  var modal = $(render('dialogs/alert', context))
      .appendTo('body');

  modal.modal({
    complete: function() {
      modal.remove();
      if (opts.complete) {
        opts.complete();
      }
    }
  });

  modal.modal('open');

  return modal;
}