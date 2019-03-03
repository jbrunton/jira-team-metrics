class JiraTeamMetrics::AgingWipChart
  include JiraTeamMetrics::ApplicationHelper

  def initialize(board, report_params)
    @board = board
    @params = report_params
  end

  def data_table
    data_table = JiraTeamMetrics::DataTableBuilder.new
      .data(wip_issues)
      .pick(:key, :summary, :started_time)
      .build

    now = DateTime.now

    data_table.add_column('now', Array.new(data_table.rows.count, now))
    data_table.insert_row(0, ['Percentiles', '85th', now - percentiles[85], now])
    data_table.insert_row(1, ['Percentiles', '70th', now - percentiles[70], now])
    data_table.insert_row(2, ['Percentiles', '50th', now - percentiles[50], now])

    data_table.insert_column(2, 'tooltip', percentile_tooltips + issue_tooltips(wip_issues, now))

    data_table
  end

  def chart_opts
    {
      colors: ['#f44336', '#ff9800', '#03a9f4'] + wip_issues.map do |issue|
        if (DateTime.now - issue.started_time) < percentiles[70]
          '#03a9f4'
        elsif (DateTime.now - issue.started_time) < percentiles[85]
          '#ff9800'
        else
          '#f44336'
        end
      end,
      height: (wip_issues.count + 3) * 41 + 50
    }
  end

  def json_data
    {
      chartOpts: chart_opts,
      data: data_table.to_json('tooltip' => { role: 'tooltip', type: 'string', p: {'html': true} }, 'started_time' => { type: 'datetime' }, 'now' => { type: 'datetime' })
    }
  end

  def render_issue_tooltip(issue, now)
    @issue_tooltip_template ||= load_template('_aging_wip_issue_tooltip.html.erb')
    @issue_tooltip_template.result(IssueTooltipBinding.new(issue, now).binding)
  end

  def render_percentile_tooltip(percentile)
    @percentile_tooltip_template ||= load_template('_aging_wip_percentile_tooltip.html.erb')
    @percentile_tooltip_template.result(PercentileTooltipBinding.new(percentile, percentiles[percentile]).binding)
  end

  private
  class IssueTooltipBinding
    def initialize(issue, now)
      @issue = issue
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

  def issue_tooltips(wip_issues, now)
    wip_issues.map{ |i| render_issue_tooltip(i, now) }
  end

  def load_template(file_name)
    ERB.new(File.read(File.join(File.expand_path(File.dirname(__FILE__)), file_name)))
  end

  def wip_issues
    issues = @board.wip_issues.select { |issue| issue.status_category == 'In Progress' }
    JiraTeamMetrics::MqlInterpreter.new
        .eval(@params.to_query, @board, issues)
        .rows
        .sort_by { |issue| issue.started_time }
  end

  def completed_issues
    query_builder = JiraTeamMetrics::QueryBuilder.new(@params.to_query, :mql)
        .and(@board.config.reports.aging_wip.default_query)
    JiraTeamMetrics::MqlInterpreter.new
        .eval(query_builder.query, @board, @board.completed_issues(@params.date_range))
        .rows
        .sort_by { |issue| issue.cycle_time }
  end

  def percentiles
    @percentiles ||= begin
      cycle_times = completed_issues.map{ |issue| issue.cycle_time }
      {
        50 => cycle_times.percentile(50),
        70 => cycle_times.percentile(70),
        85 => cycle_times.percentile(85)
      }
    end
  end
end