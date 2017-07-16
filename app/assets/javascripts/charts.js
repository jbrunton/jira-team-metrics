function drawChart(opts, jsonData) {
  var chartId = opts.id;
  var chartOpts = opts.chartOpts;
  var chartType = opts.chartType;
  var relativeHeight = opts.relativeHeight || 0.7;
  var data = new google.visualization.DataTable(jsonData);

  var $chartDiv = $('#' + chartId);
  $chartDiv.css('height', $chartDiv.width() * relativeHeight);

  var chart = new google.visualization[chartType](document.getElementById(chartId));
  chart.draw(data, chartOpts);
  $chartDiv.animate({ opacity: 1 })
}

function defineChart(opts) {
  var chartId = opts.id;
  var chartUrl = opts.url;

  function updateChart() {
    var $chartDiv = $('#' + chartId)
    $chartDiv.animate({ opacity: 0 }, {
      complete: function() {
        $chartDiv.html(render('spinner'));
        $chartDiv.animate({ opacity: 1 });
      }
    });

    function _drawChart(jsonData) {
      drawChart(opts, jsonData);
    }

    var url = buildComponentUrl(chartUrl);
    $.get(url, _drawChart);
  }

  $(function () {
    google.charts.setOnLoadCallback(updateChart);
    $('#ct-states input').change(updateChart);
    $('#ct-states textarea').change(updateChart);
  });
}

function piechart(opts) {
  opts = Object.assign({
    chartType: 'PieChart',
    relativeHeight: opts.relativeHeight || 0.7
  }, opts);

  opts.chartOpts = Object.assign({
    chartArea: {
      width: '70%'
    },
    legend: {
      alignment: 'center'
    }
  }, opts.chartOpts);

  defineChart(opts);
}

function stackedColumnChart(opts) {
  opts = Object.assign({
    chartType: 'ColumnChart',
    relativeHeight: opts.relativeHeight || 0.5
  }, opts);

  opts.chartOpts = Object.assign({
    isStacked: true,
  }, opts.chartOpts);

  defineChart(opts);
}