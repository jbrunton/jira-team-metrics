class JiraTeamMetrics::ApiController < JiraTeamMetrics::ApplicationController
  include JiraTeamMetrics::ApplicationHelper

  before_action :set_domain
  before_action :set_board

  CONTROL_CHART_COLUMNS = [
    {id: 'date', type: 'date', label: 'Completed'},
    {id: 'completed_issues', type: 'number', label: 'Completed Issues'},
    {id: 'completed_issues_tooltip', type: 'string', role: 'tooltip'},
    {id: 'wip', type: 'number', label: 'WIP'},
    {id: 'ct_avg', type: 'number', label: 'Rolling Avg CT'},
    {id: 'ct_interval_min', type: 'number', role: 'interval'},
    {id: 'ct_interval_max', type: 'number', role: 'interval'},
    {id: 'wip_avg', type: 'number', label: 'Rolling Avg WIP'},
    {id: 'wip_interval_min', type: 'number', role: 'interval'},
    {id: 'wip_interval_max', type: 'number', role: 'interval'},
    {id: 'completed_issues_key', type: 'string', role: 'annotation'}
  ]

  COMPLETED_ISSUES_COL = CONTROL_CHART_COLUMNS.find_index{ |c| c[:id] == 'completed_issues' }
  COMPLETED_ISSUES_KEY_COL = CONTROL_CHART_COLUMNS.find_index{ |c| c[:id] == 'completed_issues_key' }
  WIP_COL = CONTROL_CHART_COLUMNS.find_index{ |c| c[:id] == 'wip' }

  def completed_summary
    render json: summary_data_table(completed_issues) { count('key') }.to_json
  end

  def completed_summary_by_month
    data_table = summarize_by_month(completed_issues,
      select_by: 'completed', aggregate_by: :count, pivot_on: 'key')

    render json: data_table.to_json
  end

  def effort_summary
    render json: summary_data_table(completed_issues) { sum('cycle_time') }.to_json
  end

  def effort_summary_by_month
    data_table = summarize_by_month(completed_issues,
      select_by: 'completed', aggregate_by: :sum, pivot_on: 'cycle_time')

    render json: data_table.to_json
  end

  def created_summary
    render json: summary_data_table(created_issues) { count('key') }.to_json
  end

  def created_summary_by_month
    data_table = summarize_by_month(created_issues,
      select_by: 'issue_created', aggregate_by: :count, pivot_on: 'key')

    render json: data_table.to_json
  end

  def cycle_time_summary
    series = (params[:series] || '').split(',')
    summary_table = @board.summarize
    render json: build_ct_table(summary_table, series)
  end

  def cycle_time_summary_by_month
    series = (params[:series] || '').split(',')

    summary_table = @board.summarize('month')

    results = {}

    JiraTeamMetrics::BoardDecorator::ISSUE_TYPE_ORDERING.each do |issue_type|
      issues = summary_table.map do |range, rows|
        row = rows.find{ |r| r.issue_type == issue_type }
        if row.nil?
          JiraTeamMetrics::BoardDecorator::SummaryRow.new(range, JiraTeamMetrics::IssuesDecorator.new([]), JiraTeamMetrics::IssuesDecorator.new([]))
        else
          row.with_new_label(range)
        end
      end

      results[issue_type] = build_ct_table(issues, series)
    end

    render json: results
  end

  def scatterplot
    render json: chart_data_for(:scatterplot)
  end

  def aging_wip
    render json: chart_data_for(:aging_wip)
  end

  def control_chart
    sorted_issues = @board.completed_issues.sort_by { |issue| issue.completed }
    ct_trends = CT_TREND_BUILDER.analyze(sorted_issues)

    wip_history = @board.wip_history.map{ |date, issues| [date, issues.count] }
    wip_trends = WIP_TREND_BUILDER.analyze(wip_history)

    render json: {
      cols: CONTROL_CHART_COLUMNS,
      rows: sorted_issues.map.with_index do |issue, index|
        mean = ct_trends[index][:mean]
        stddev = ct_trends[index][:stddev]
        {c: [
          {v: date_as_string(issue.completed)},
          {v: issue.cycle_time},
          {v: "#{issue.key} - #{issue.summary.truncate(40)}"},
          {v: nil},
          {v: mean},
          {v: mean - stddev},
          {v: mean + stddev},
          {v: nil}, {v: nil}, {v: nil}, # wip
          {v: issue.key }
        ]}
      end + wip_history.map.with_index do |x, index|
        #byebug
        date, wip = x
        mean = wip_trends[index][:mean]
        stddev = wip_trends[index][:stddev]
        {c: [{v: date_as_string(date)}, {v: nil}, {v: nil}, {v: wip}, {v: nil}, {v: nil}, {v: nil}, {v: mean}, {v: mean - stddev}, {v: mean + stddev}, {v: nil}]}
      end
    }
  end

private
  def build_ct_table(summary_table, series)
    builder = JiraTeamMetrics::JsonDataTableBuilder.new
      .column({type: 'string', label: 'Issue Type'}, summary_table.map(&:issue_type_label))
      .number({label: 'Mean', id: 'mean'}, summary_table.map(&:ct_mean))
      .number({label: 'Median', id: 'median'}, summary_table.map(&:ct_median))

    if series.include?('min-max')
      builder.number({id: 'min', label: 'Min'}, summary_table.map(&:ct_min))
      builder.number({id: 'max', label: 'Max'}, summary_table.map(&:ct_max))
    end

    builder.number({id: 'p25', label: 'Lower Quartile'}, summary_table.map(&:ct_p25))
    builder.number({id: 'p75', label: 'Upper Quartile'}, summary_table.map(&:ct_p75))

    if series.include?('p10-p90')
      builder.number({id: 'p10', label: '10th Percentile'}, summary_table.map(&:ct_p10))
      builder.number({id: 'p90', label: '90th Percentile'}, summary_table.map(&:ct_p90))
      builder.interval({id: 'i:p10'}, summary_table.map(&:ct_p10))
      builder.interval({id: 'i:p90'}, summary_table.map(&:ct_p90))
    end

    builder.interval({id: 'i:p25'}, summary_table.map(&:ct_p25))
    builder.interval({id: 'i:median'}, summary_table.map(&:ct_median))
    builder.interval({id: 'i:p75'}, summary_table.map(&:ct_p75))

    builder.build
  end

  def build_count_table(summary_table, series)
    builder = JsonDataTableBuilder.new
      .column({type: 'string', label: 'Issue Type'}, summary_table.map(&:issue_type_label))
      .number({label: 'Count', id: 'count'}, summary_table.map(&:count))

    builder.build
  end

  def completed_issues
    issues = @board.completed_issues.select do |issue|
      @board.date_range.start_date <= issue.completed &&
        issue.completed < @board.date_range.end_date
    end
    JiraTeamMetrics::DataTableBuilder.new
      .data(issues)
      .pick(:key, :issue_type, :cycle_time, :completed)
      .build
  end

  def created_issues
    all_created_issues = @board.object.issues.select do |issue|
      @board.date_range.start_date <= issue.issue_created &&
        issue.issue_created < @board.date_range.end_date
    end
    if params[:query].blank?
      issues = all_created_issues
    else
      issues = JiraTeamMetrics::MqlInterpreter.new(@board, all_created_issues).eval(params[:query])
    end
    JiraTeamMetrics::DataTableBuilder.new
      .data(issues)
      .pick(:key, :issue_type, :issue_created)
      .build
  end

  def summarize_by_month(issues, opts)
    issues
      .map(opts[:select_by]) { |date| DateTime.new(date.year, date.month) }
      .select(opts[:select_by]).send(opts[:aggregate_by], @board.issue_types)
      .pivot(opts[:pivot_on], for: 'issue_type', in: @board.issue_types, if_nil: 0)
      .sort_by(opts[:select_by])
      .map(opts[:select_by]) { |date| date.strftime('%b %Y') }
  end

  def summary_data_table(data_table, &block)
    selector = data_table.select('issue_type')
    selector.instance_eval(&block)
      .group
      .sort_by('issue_type') { |issue_type| -(JiraTeamMetrics::BoardDecorator::ISSUE_TYPE_ORDERING.reverse.index(issue_type) || -1) }
  end

  def chart_data_for(chart_name)
    chart_params = JiraTeamMetrics::ChartParams.new(
      query: params[:query],
      date_range: JiraTeamMetrics::DateRange.new(params[:from_date], params[:to_date])
    )
    chart_class = "JiraTeamMetrics::#{chart_name.to_s.camelize}Chart".constantize
    chart_class.new(@board, chart_params).json_data
  end

  CT_TREND_BUILDER = JiraTeamMetrics::TrendBuilder.new.
    pluck{ |issue| issue.cycle_time }.
    map do |issue, mean, stddev|
    { issue: issue, cycle_time: issue.cycle_time, mean: mean, stddev: stddev }
  end

  WIP_TREND_BUILDER = JiraTeamMetrics::TrendBuilder.new.
    pluck{ |item| item[1] }.
    map do |item, mean, stddev|
    {wip: item[1], mean: mean, stddev: stddev }
  end
end