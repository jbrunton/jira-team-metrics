function piechart(opts) {
  var chartId = opts.id;
  var chartUrl = opts.url;
  var title = opts.title;

  function chartDiv() {
    return $('#' + chartId);
  }

  function updateChart() {
    chartDiv().animate({ opacity: 0 }, {
      complete: function() {
        $chartDiv = chartDiv();
        $chartDiv.html(render('spinner'));
        $chartDiv.animate({ opacity: 1 });
      }
    });
    var url = buildComponentUrl(chartUrl);
    $.get(url, drawChart);
  }

  function drawChart(jsonData) {
    var data = new google.visualization.DataTable(jsonData);

    var options = {
      title: title,
      chartArea: {
        width: '70%'
      },
      legend: {
        alignment: 'center'
      }
    };

    $chartDiv = chartDiv();
    $chartDiv.css('height', $chartDiv.width() * 0.7);

    var chart = new google.visualization.PieChart(document.getElementById(chartId));
    chart.draw(data, options);
    $chartDiv.animate({ opacity: 1 })
  }

  $(function () {
    google.charts.setOnLoadCallback(updateChart);
    $('#ct-states input').change(updateChart);
    $('#ct-states textarea').change(updateChart);
  });
}

function stackedColumnChart(opts) {
  var chartId = opts.id;
  var chartUrl = opts.url;
  var title = opts.title;

  function chartDiv() {
    return $('#' + chartId);
  }

  function updateChart() {
    chartDiv().animate({ opacity: 0 }, {
      complete: function() {
        $chartDiv = chartDiv();
        $chartDiv.html(render('spinner'));
        $chartDiv.animate({ opacity: 1 });
      }
    });
    var url = buildComponentUrl(chartUrl);
    $.get(url, drawChart);
  }

  function drawChart(jsonData) {
    var data = new google.visualization.DataTable(jsonData);

    var options = {
      title: title,
      isStacked: true
    };

    $chartDiv = chartDiv();
    $chartDiv.css('height', $chartDiv.width() * 0.5);

    var chart = new google.visualization.ColumnChart(document.getElementById(chartId));
    chart.draw(data, options);
    $chartDiv.animate({ opacity: 1 })
  }

  $(function () {
    google.charts.setOnLoadCallback(updateChart);
    $('#ct-states input').change(updateChart);
    $('#ct-states textarea').change(updateChart);
  });
}