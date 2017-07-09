require './app/models/data_table_builder'

class ApiController < ApplicationController
  include ApplicationHelper

  before_action :set_domain
  before_action :set_board

  def count_summary
    summary_table = @board.summarize

    builder = DataTableBuilder.new
      .column({id: 'issue_type', type: 'string', label: 'Issue Type'}, summary_table.map(&:issue_type))
      .column({id: 'count', type: 'number', label: 'Count' }, summary_table.map(&:count))

    render json: builder.build
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

    BoardDecorator::ISSUE_TYPE_ORDERING.each do |issue_type|
      issues = summary_table.map do |range, rows|
        row = rows.find{ |r| r.issue_type == issue_type }
        if row.nil?
          BoardDecorator::SummaryRow.new(range, IssuesDecorator.new([]), IssuesDecorator.new([]))
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
      cols: [
        {id: 'date', type: 'date', label: 'Completed'},
        {id: 'completed_issues', type: 'number', label: 'Completed Issues'},
        {id: 'completed_issues_key', type: 'string', role: 'tooltip'},
        {id: 'wip', type: 'number', label: 'WIP'},
        {id: 'ct_avg', type: 'number', label: 'Rolling Avg CT'},
        {id: 'ct_interval_min', type: 'number', role: 'interval'},
        {id: 'ct_interval_max', type: 'number', role: 'interval'},
        {id: 'wip_avg', type: 'number', label: 'Rolling Avg WIP'},
        {id: 'wip_interval_min', type: 'number', role: 'interval'},
        {id: 'wip_interval_max', type: 'number', role: 'interval'}
      ],
      rows: sorted_issues.map.with_index do |issue, index|
        mean = ct_trends[index][:mean]
        stddev = ct_trends[index][:stddev]
        {c: [{v: date_as_string(issue.completed)}, {v: issue.cycle_time}, {v: issue.key}, {v: nil}, {v: mean}, {v: mean - stddev}, {v: mean + stddev}, {v: nil}, {v: nil}, {v: nil}]}
      end + wip_history.map.with_index do |x, index|
        #byebug
        date, wip = x
        mean = wip_trends[index][:mean]
        stddev = wip_trends[index][:stddev]
        {c: [{v: date_as_string(date)}, {v: nil}, {v: nil}, {v: wip}, {v: nil}, {v: nil}, {v: nil}, {v: mean}, {v: mean - stddev}, {v: mean + stddev},]}
      end
    }
  end

  def compare
    sorted_issues = @board.completed_issues.sort_by { |issue| issue.cycle_time }
    selected_issues = IssuesDecorator.new(params[:selection_query].blank? ? [] : MqlInterpreter.new(sorted_issues).eval(params[:selection_query]))
    other_issues = IssuesDecorator.new(sorted_issues.select{ |issue| !selected_issues.include?(issue) })

    chart_data = data_for_compare_chart(sorted_issues, selected_issues, other_issues)

    others_q1 = other_issues.cycle_times.percentile(25)
    others_q3 = other_issues.cycle_times.percentile(75)

    selected_lt_q3 = selected_issues.select{ |issue| issue.cycle_time <= others_q3 }

    render json: {
      chartData: chart_data,
      quartiles: {
        dev: {
          q1: selected_issues.cycle_times.percentile(25),
          q3: selected_issues.cycle_times.percentile(75),
          percentLtQ3: selected_lt_q3.count.to_f / selected_issues.count * 100,
          percentGtQ3: (selected_issues.count - selected_lt_q3.count).to_f / selected_issues.count * 100
        },
        others: {
          q1: others_q1,
          q3: others_q3
        }
      }
    }
  end

private
  def build_ct_table(summary_table, series)
    builder = DataTableBuilder.new
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

  def data_for_compare_chart(sorted_issues, selected_issues, other_issues)
    selected_rows = selected_issues.map do |issue|
      rank = sorted_issues.count - sorted_issues.index(issue)
      {c: [{v: rank}, {v: issue.cycle_time}, {v: nil}]}
    end
    other_rows = other_issues.map do |issue|
      rank = sorted_issues.count - sorted_issues.index(issue)
      {c: [{v: rank}, {v: nil}, {v: issue.cycle_time}]}
    end
    {
      cols: [
        {id: 'rank', type: 'number', label: 'Rank'},
        {id: 'ct_selected', type: 'number', label: 'Cycle Time (Selected)'},
        {id: 'ct_other', type: 'number', label: 'Cycle Time (Others)'}
      ],
      rows: selected_rows + other_rows
    }
  end

  CT_TREND_BUILDER = TrendBuilder.new.
    pluck{ |issue| issue.cycle_time }.
    map do |issue, mean, stddev|
    { issue: issue, cycle_time: issue.cycle_time, mean: mean, stddev: stddev }
  end

  WIP_TREND_BUILDER = TrendBuilder.new.
    pluck{ |item| item[1] }.
    map do |item, mean, stddev|
    {wip: item[1], mean: mean, stddev: stddev }
  end
end