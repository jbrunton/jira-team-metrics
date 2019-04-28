class JiraTeamMetrics::AgingWipChart
  def initialize(board, report_params)
    @board = board
    @params = report_params
  end

  def data_table
    interpreter = JiraTeamMetrics::MqlInterpreter.new
    results = interpreter.eval(
      "select key, age('#{@params.aging_type}'), key as annotation from issues()",
      @board, wip_issues)
    data_table = results.to_data_table

    now = DateTime.now

    data_table.add_column('style', issue_styles(now))
    data_table.insert_row(0, ['85th', percentiles[85], '85th percentile', 'color: #f44336'])
    data_table.insert_row(1, ['70th', percentiles[70], '75th percentile', 'color: #ff9800'])
    data_table.insert_row(2, ['50th', percentiles[50], '50th percentile', 'color: #03a9f4'])

    data_table.insert_column(2, 'tooltip', percentile_tooltips + issue_tooltips(now))

    data_table.insert_row(3, [nil, nil, nil, nil, nil])

    data_table
  end

  def chart_opts
    {
      height: (wip_issues.count + 4) * 24,
      chartArea: { width: '100%', height: '100%' },
      bar: { groupWidth: '80%' },
      tooltip: { isHtml: true },
      legend: { position: 'none' },
      vAxis: { textPosition: 'none' },
      annotations: {
        textStyle: {
          fontSize: 12
        }
      }
    }
  end

  def json_data
    {
      chartOpts: chart_opts,
      data: data_table.to_json('tooltip' => { role: 'tooltip', type: 'string', p: {'html': true} }, 'age' => { type: 'number' }, 'annotation' => { role: 'annotation' }, 'style' => { role: 'style' })
    }
  end

  def render_issue_tooltip(issue, now)
    @issue_tooltip_template ||= load_template('_aging_wip_issue_tooltip.html.erb')
    @issue_tooltip_template.result(IssueTooltipBinding.new(issue, @params.aging_type, now).binding)
  end

  def render_percentile_tooltip(percentile)
    @percentile_tooltip_template ||= load_template('_aging_wip_percentile_tooltip.html.erb')
    @percentile_tooltip_template.result(PercentileTooltipBinding.new(percentile, percentiles[percentile]).binding)
  end

  private
  class IssueTooltipBinding
    include JiraTeamMetrics::HtmlHelper

    def initialize(issue, age_type, now)
      @issue = issue
      @age_type = age_type
      @now = now
    end

    def binding
      super
    end
  end

  class PercentileTooltipBinding
    def initialize(percentile, duration)
      @percentile = percentile
      @duration = duration
    end

    def binding
      super
    end
  end

  def percentile_tooltips
    [85, 70, 50].map{ |p| render_percentile_tooltip(p) }
  end

  def issue_tooltips(now)
    wip_issues.map{ |i| render_issue_tooltip(i, now) }
  end

  def issue_styles(now)
    wip_issues.map do |issue|
      if issue.age(@params.aging_type, now) < percentiles[70]
        '#03a9f4'
      elsif issue.age(@params.aging_type, now) < percentiles[85]
        '#ff9800'
      else
        '#f44336'
      end
    end
  end

  def load_template(file_name)
    ERB.new(File.read(File.join(File.expand_path(File.dirname(__FILE__)), file_name)))
  end

  def wip_issues
    @wip_issues ||= begin
      issues = @board.wip_issues.select { |issue| issue.status_category == 'In Progress' }
      JiraTeamMetrics::MqlInterpreter.new
          .eval(@params.to_query, @board, issues)
          .rows
          .sort_by { |issue| -issue.age(@params.aging_type, DateTime.now) }
    end
  end

  def completed_issues
    query_builder = JiraTeamMetrics::QueryBuilder.new(@params.to_query, :mql)
        .and(@board.config.reports.aging_wip.default_query)
    JiraTeamMetrics::MqlInterpreter.new
        .eval(query_builder.query, @board, @board.completed_issues(@params.date_range))
        .rows
        .sort_by { |issue| -issue.age(@params.aging_type, DateTime.now) }
  end

  def percentiles
    @percentiles ||= begin
      cycle_times = completed_issues.map{ |issue| issue.age(@params.aging_type, DateTime.now) }
      {
        50 => cycle_times.percentile(50),
        70 => cycle_times.percentile(70),
        85 => cycle_times.percentile(85)
      }
    end
  end
end