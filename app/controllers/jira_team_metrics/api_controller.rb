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

  def count_summary
    render json: summary_data_table(completed_issues) { count('key') }.to_json
  end

  def count_summary_by_month
    data_table = monthly_summary_data_table(completed_issues,
      pick: [:issue_type, :completed],
      sort_by: 'completed',
      group_by: [['issue_type', 'completed'], :count, of: 'issue_type', as: 'Count'],
      pivot_on: ['issue_type', from: @board.issue_types, select: 'Count', if_nil: 0])

    render json: data_table.to_json
  end

  def effort_summary
    render json: summary_data_table(completed_issues) { sum('cycle_time') }.to_json
  end

  def effort_summary_by_month
    data_table = monthly_summary_data_table(completed_issues,
      pick: [:issue_type, :completed, :cycle_time],
      sort_by: 'completed',
      group_by: [['issue_type', 'completed'], :sum, of: 'cycle_time', as: 'Days'],
      pivot_on: ['issue_type', from: @board.issue_types, select: 'Days', if_nil: 0])
    render json: data_table.to_json
  end

  def created_summary
    render json: summary_data_table(created_issues) { count('key') }.to_json
  end

  def created_summary_by_month
    data_table = monthly_summary_data_table(created_issues,
      pick: [:issue_type, :issue_created],
      sort_by: 'issue_created',
      group_by: [['issue_type', 'issue_created'], :count, of: 'issue_type', as: 'Count'],
      pivot_on: ['issue_type', from: @board.issue_types, select: 'Count', if_nil: 0])

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

  def compare
    sorted_issues = IssuesDecorator.new(@board.completed_issues.sort_by { |issue| issue.cycle_time })
    selected_issues = IssuesDecorator.new(params[:selection_query].blank? ? [] : MqlInterpreter.new(sorted_issues, @board).eval(params[:selection_query]))
    other_issues = IssuesDecorator.new(sorted_issues.select{ |issue| !selected_issues.include?(issue) })

    chart_data = data_for_compare_chart(sorted_issues, selected_issues, other_issues)
    histogram_data = data_for_compare_histogram(sorted_issues, selected_issues)
    quartiles_data = data_for_compare_quartiles(sorted_issues, selected_issues)

    render json: {
      chartData: chart_data,
      histogramData: histogram_data,
      quartiles: quartiles_data
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

  def data_for_compare_chart(sorted_issues, selected_issues, other_issues)
    selected_rows = selected_issues.map do |issue|
      percentile = (sorted_issues.index(issue) + 1).to_f / sorted_issues.count * 100
      {c: [{v: percentile}, {v: issue.cycle_time}, {v: nil}]}
    end
    other_rows = other_issues.map do |issue|
      percentile = (sorted_issues.index(issue) + 1).to_f / sorted_issues.count * 100
      {c: [{v: percentile}, {v: nil}, {v: issue.cycle_time}]}
    end
    {
      cols: [
        {id: 'percentile', type: 'number', label: 'Percentile'},
        {id: 'ct_selected', type: 'number', label: 'Cycle Time (Selected)'},
        {id: 'ct_other', type: 'number', label: 'Cycle Time (Others)'}
      ],
      rows: selected_rows + other_rows
    }
  end

  def data_for_compare_histogram(sorted_issues, selected_issues)
    selected_rows = selected_issues.map do |issue|
      percentile = (sorted_issues.index(issue) + 1).to_f / sorted_issues.count * 100
      {c: [{v: issue.key}, {v: percentile}]}
    end
    {
      cols: [
        {id: 'issue', type: 'string', label: 'Issue'},
        {id: 'percentile', type: 'number', label: 'Percentile'},
      ],
      rows: selected_rows
    }
  end

  def data_for_compare_quartiles(sorted_issues, selected_issues)
    q1 = sorted_issues.cycle_times.percentile(25)
    q2 = sorted_issues.cycle_times.percentile(50)
    q3 = sorted_issues.cycle_times.percentile(75)

    total_q1 = selected_issues.select{ |issue| issue.cycle_time <= q1 }.count
    total_q2 = selected_issues.select{ |issue| q1 < issue.cycle_time && issue.cycle_time <= q2 }.count
    total_q3 = selected_issues.select{ |issue| q2 < issue.cycle_time && issue.cycle_time <= q3 }.count
    total_q4 = selected_issues.select{ |issue| q3 < issue.cycle_time }.count

    {
      q1: {
        total: total_q1,
        percent: total_q1.to_f / selected_issues.count * 100
      },
      q2: {
        total: total_q2,
        percent: total_q2.to_f / selected_issues.count * 100
      },
      q3: {
        total: total_q3,
        percent: total_q3.to_f / selected_issues.count * 100
      },
      q4: {
        total: total_q4,
        percent: total_q4.to_f / selected_issues.count * 100
      }
    }
  end

  def completed_issues
    @board.completed_issues.select do |issue|
      @board.date_range.start_date <= issue.completed &&
        issue.completed < @board.date_range.end_date
    end
  end

  def created_issues
    all_created_issues = @board.object.issues.select do |issue|
      @board.date_range.start_date <= issue.issue_created &&
        issue.issue_created < @board.date_range.end_date
    end
    JiraTeamMetrics::MqlInterpreter.new(@board, all_created_issues).eval(params[:query])
  end

  def summary_data_table(issues, &block)
    pick_opts = [:key, :issue_type]
    pick_opts << :cycle_time if issues.any? && issues[0].is_a?(JiraTeamMetrics::IssueDecorator)

    selector = JiraTeamMetrics::DataTableBuilder.new
      .data(issues)
      .pick(*pick_opts)
      .build
      .select('issue_type')

    selector.instance_eval(&block)
      .group
      .sort_by('issue_type') { |issue_type| -(JiraTeamMetrics::BoardDecorator::ISSUE_TYPE_ORDERING.reverse.index(issue_type) || -1) }
  end

  def monthly_summary_data_table(issues, opts)
    JiraTeamMetrics::DataTableBuilder.new
      .data(issues)
      .pick(*opts[:pick])
      .build
      .sort_by('issue_type') { |issue_type| -(JiraTeamMetrics::BoardDecorator::ISSUE_TYPE_ORDERING.reverse.index(issue_type) || -1) }
      .group_by(*opts[:group_by]) do |issue_type, date|
        [issue_type, DateTime.new(date.year, date.month)]
      end
      .sort_by(opts[:sort_by])
      .map(opts[:sort_by]) { |date| date.strftime('%b %Y') }
      .pivot_on(*opts[:pivot_on])
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