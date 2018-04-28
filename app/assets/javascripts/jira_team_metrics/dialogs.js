function alertModal(opts) {
  return _modal(Object.assign({
    title: '',
    body: '<p>' + opts.message + '</p>',
    modalClass: 'ui modal',
    negativeAction: null
  }, opts));
}

function fixedFooterModal(opts) {
  return _modal(Object.assign({
    modalClass: 'ui modal modal-fixed-footer'
  }, opts));
}

function modal(opts) {
  return _modal(Object.assign({
    modalClass: 'ui modal'
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

  //if (Materialize) {
  //  Materialize.updateTextFields();
  //}
  $modal.find('.materialize-textarea').trigger('autoresize');

  addHandler('.ui.positive.button', 'confirm');
  addHandler('.ui.negative.button', 'cancel');

  $modal.modal({
    onHidden: function() {
      $modal.remove();
      if (opts.complete) {
        opts.complete($modal);
      }
    }
  })
  .modal('show');

  return $modal;
}