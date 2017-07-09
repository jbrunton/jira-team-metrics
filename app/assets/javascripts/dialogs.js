function alertModal(opts) {
  return _modal(Object.assign({
    title: '',
    body: '<p>' + opts.message + '</p>',
    modalClass: 'modal',
    positiveAction: {
      text: 'OK'
    }
  }, opts));
}

function fixedFooterModal(opts) {
  return _modal(Object.assign({
    modalClass: 'modal modal-fixed-footer',
    positiveAction: {
      text: 'OK'
    },
    negativeAction: {
      text: 'Cancel'
    }
  }, opts));
}

function modal(opts) {
  return _modal(Object.assign({
    modalClass: 'modal',
    positiveAction: {
      text: 'OK'
    },
    negativeAction: {
      text: 'Cancel'
    }
  }, opts));
}

function _modal(opts) {
  var $modal = $(render('dialogs/modal', opts))
      .appendTo('body');

  if (Materialize) {
    Materialize.updateTextFields();
  }
  $modal.find('.materialize-textarea').trigger('autoresize');

  $modal.find('.modal-ok').click(function() {
    if (opts.confirm) {
      opts.confirm($modal);
    }
  });

  $modal.find('.modal-cancel').click(function() {
    if (opts.cancel) {
      opts.cancel($modal);
    }
  });

  $modal.modal('open', {
    complete: function() {
      if (opts.complete) {
        opts.complete($modal);
      }
      $modal.remove();
    }
  });

  return $modal;
}