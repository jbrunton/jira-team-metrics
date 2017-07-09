function alertModal(opts) {
  return _modal(Object.assign({
    title: '',
    body: '<p>' + opts.message + '</p>',
    modalClass: 'modal',
    negativeAction: null
  }, opts));
}

function fixedFooterModal(opts) {
  return _modal(Object.assign({
    modalClass: 'modal modal-fixed-footer'
  }, opts));
}

function modal(opts) {
  return _modal(Object.assign({
    modalClass: 'modal'
  }, opts));
}

function _modal(opts) {
  opts = Object.assign({
    positiveAction: {
      text: 'OK'
    },
    negativeAction: {
      text: 'Cancel'
    }
  }, opts);
  function addHandler(selector, handlerName) {
    $modal.find(selector).click(function() {
      if (opts[handlerName]) {
        opts[handlerName]($modal);
      }
    });
  }

  var $modal = $(render('dialogs/modal', opts))
      .appendTo('body');

  Materialize.updateTextFields();
  $modal.find('.materialize-textarea').trigger('autoresize');

  addHandler('.modal-ok', 'confirm');
  addHandler('.modal-cancel', 'cancel');

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