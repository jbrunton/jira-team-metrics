describe('alertModal', function() {
  var title = 'Some title',
      message = 'Some message';

  it("shows a modal", function() {
    var modal = alertModal({
      title: title,
      message: message
    });

    expect(modal).toBeVisible();
    expect(modal.find('.modal-content h4')).toHaveText(title);
    expect(modal.find('.modal-content p')).toHaveText(message);
  });

  it("is dismissable", function(done) {
    var modal = alertModal({
      title: title,
      message: message,
      complete: function() {
        expect(modal).not.toBeVisible();
        done();
      }
    });

    modal.find('.modal-ok').click();
  });
});
