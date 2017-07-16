function ChartBuilder(id) {
  this._opts = { id: id };
  _.bindAll(this, _.functions(ChartBuilder.prototype));
}

ChartBuilder.prototype.chartType = function(chartType) {
  this._opts.chartType = chartType;

  switch (chartType) {
    case 'PieChart':
      this._opts = Object.assign({
        chartType: 'PieChart',
        relativeHeight: 0.7
      }, this._opts);

      this._opts.chartOpts = Object.assign({
        chartArea: {
          width: '70%'
        },
        legend: {
          alignment: 'center'
        }
      }, this._opts.chartOpts);
      break;
    case 'ColumnChart':
      this._opts = Object.assign({
        chartType: 'ColumnChart',
        relativeHeight: 0.5
      }, this._opts);
      break;
  }

  return this;
}

ChartBuilder.prototype.chartOpts = function(chartOpts) {
  this._opts.chartOpts = chartOpts;
  return this;
}

ChartBuilder.prototype.relativeHeight = function(relativeHeight) {
  this._opts.relativeHeight = relativeHeight;
  return this;
}

ChartBuilder.prototype.url = function(url) {
  this._opts.url = url;
  return this;
}

ChartBuilder.prototype.build = function() {
  return new Chart(this._opts);
}

function Chart(opts) {
  this._id = opts.id;
  this._chartType = opts.chartType;
  this._chartOpts = opts.chartOpts;
  this._relativeHeight = opts.relativeHeight;
  this._url = opts.url;

  _.bindAll(this, _.functions(Chart.prototype));
}

Chart.prototype._findContainer = function() {
  return $('#' + this._id);
}

Chart.prototype.draw = function(jsonData) {
  var data = new google.visualization.DataTable(jsonData);

  var $container = this._findContainer();
  $container.css('height', $container.width() * this._relativeHeight);

  var chart = new google.visualization[this._chartType](document.getElementById(this._id));
  chart.draw(data, this._chartOpts);

  this.loading(false);
}

Chart.prototype.refresh = function() {
  this.loading(true);
  var url = buildComponentUrl(this._url);
  $.get(url, this.draw);
}

Chart.prototype.loading = function(loading) {
  var $container = this._findContainer();
  if (loading) {
    $container.html(render('spinner'));
  }
}
