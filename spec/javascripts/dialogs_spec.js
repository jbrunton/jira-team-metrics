describe('alertModal', function() {
  var title = 'Some title',
      message = 'Some message';

  it("shows a modal", function() {
    var modal = alertModal({
      title: title,
      message: message
    });

    expect(modal).toBeVisible();
    expect(modal.find('.header')).toHaveText(title);
    expect(modal.find('.content')).toHaveText(message);
  });

  xit("is dismissable", function(done) {
    var modal = alertModal({
      title: title,
      message: message,
      complete: function() {
        expect(modal).not.toBeVisible();
        done();
      }
    });

    modal.find('.ui.positive.button').click();
  });
});
