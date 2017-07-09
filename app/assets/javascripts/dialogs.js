function alertModal(opts) {
  return modal(Object.assign({
    body: '<p>' + opts.message + '</p>',
    modalClass: 'modal',
    positiveAction: {
      text: 'OK'
    }
  }, opts));
}

function fixedFooterModal(opts) {
  return modal(Object.assign({
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
  var context = {
    title: opts.title,
    modalClass: opts.modalClass
  };
  if (opts.bodyHtml) {
    context.body = '<div id="modal-body"></div>';
  } else {
    context.body = opts.body;
  }

  var modal = $(render('dialogs/modal', opts))
      .appendTo('body');

  if (opts.render) {
    opts.render(modal);
  }

  if (opts.bodyHtml) {
    modal.find('#modal-body').html(opts.bodyHtml);
  }

  modal.find('.modal-ok').click(function() {
    if (opts.confirm) {
      opts.confirm();
    }
  });

  modal.find('.modal-cancel').click(function() {
    if (opts.cancel) {
      opts.cancel();
    }
  });

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