function piechart(chartUrl, chartId) {
  (function() {
    function updateChart() {
      var url = buildComponentUrl(chartUrl);
      $.get(url, drawChart);
    }

    function drawChart(jsonData) {
      var data = new google.visualization.DataTable(jsonData);

      var options = {
        legend: {
          alignment: 'center'
        }
      };

      var chartDiv = $('#' + chartId);
      chartDiv.css('height', chartDiv.width() * 0.8);

      var chart = new google.visualization.PieChart(document.getElementById(chartId));
      chart.draw(data, options);
    }

    $(function () {
      google.charts.setOnLoadCallback(updateChart);
      $('#ct-states input').change(updateChart);
      $('#ct-states textarea').change(updateChart);
    });
  })();
}