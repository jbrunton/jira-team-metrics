function statusReceived(data) {
  if (data.in_progress) {
    $('#sync-indicator').show();
    if (data.progress === 'number') {
      $('.progress #indicator').addClass('determinate').removeClass('indeterminate').css('width', data.progress + '%');
    } else {
      $('.progress #indicator').addClass('indeterminate').removeClass('determinate').css('width', '');
    }
    $('#sync-status-title').text(data.statusTitle);
    $('#sync-status').text(data.status);
  } else {
    $('#sync-indicator').hide();
    if (data.error) {
      alertModal({
        title: 'Sync error',
        message: data.error,
        complete: function() {
          showSyncModal();
        }
      });
    } else {
      location.reload();
    }
  }
}
