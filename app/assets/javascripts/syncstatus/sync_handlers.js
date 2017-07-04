function statusReceived(data) {
  if (data.in_progress) {
    $('#sync-indicator').show();
    if (data.progress === null) {
      $('.progress #indicator').addClass('indeterminate').removeClass('determinate').css('width', '');
    } else {
      $('.progress #indicator').addClass('determinate').removeClass('indeterminate').css('width', data.progress + '%');
    }
    $('#sync-status-title').text(data.statusTitle);
    $('#sync-status').text(data.status);
  } else {
    $('#sync-indicator').hide();
    if (data.error) {
      if (data.errorCode === '401') {
        alertModal({
          title: 'Sync error',
          message: data.error + '. Please check your credentials.',
          complete: function() {
            $('#sync-modal').modal('open');
          }
        });
      } else {
        alertModal({
          title: 'Sync error',
          message: data.error
        });
      }
    } else {
      location.reload();
    }
  }
}
