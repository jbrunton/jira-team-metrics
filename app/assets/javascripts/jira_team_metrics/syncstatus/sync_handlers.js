function statusReceived(data) {
  if (data.in_progress) {
    $('#sync-indicator').show();
    if (typeof(data.progress) !== 'undefined') {
      $('#indicator-indeterminate').hide();
      $('#indicator-determinate').show().progress({ percent: data.progress, autoSuccess: false });
    } else {
      $('#indicator-indeterminate').show();
      $('#indicator-determinate').hide();
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

$(function() {
  $('#indicator-indeterminate').progress({
    percent: 100,
    autoSuccess: false
  });
  setTimeout(function() {
    // A hack to show the active animation, which otherwise is disabled on completion
    $('#indicator-indeterminate').addClass('active');
  }, 1000);
});