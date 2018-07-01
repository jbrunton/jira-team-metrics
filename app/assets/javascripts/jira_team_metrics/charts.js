function defineChart(opts) {
  var chartId = opts.id;
  var chartUrl = opts.url;
  var chartOpts = opts.chartOpts;
  var chartType = opts.chartType;
  var relativeHeight = opts.relativeHeight || 0.7;

  function chartDiv() {
    return $('#' + chartId);
  }

  function updateChart() {
    chartDiv().animate({ opacity: 0 }, {
      complete: function() {
        var $chartDiv = chartDiv();
        $chartDiv.html(render('spinner'));
        $chartDiv.animate({ opacity: 1 });
      }
    });
    var url = buildComponentUrl(chartUrl);
    $.get(url, drawChart);
  }

  function drawChart(jsonData) {
    var data = new google.visualization.DataTable(jsonData);

    var $chartDiv = chartDiv();
    $chartDiv.css('height', $chartDiv.width() * relativeHeight);

    var chart = new google.visualization[chartType](document.getElementById(chartId));
    chart.draw(data, chartOpts);
    $chartDiv.animate({ opacity: 1 })
  }

  $(function () {
    google.charts.setOnLoadCallback(updateChart);
    $('#ct-states select').change(updateChart);
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
    isStacked: true
  }, opts.chartOpts);

  defineChart(opts);
}