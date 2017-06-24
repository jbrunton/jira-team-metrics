class ApiController < ApplicationController
  get '/:domain/boards/:board_id/count_summary.json' do
    summary_table = @board.summarize

    builder = DataTableBuilder.new
      .column({id: 'issue_type', type: 'string', label: 'Issue Type'}, summary_table.map(&:issue_type))
      .column({id: 'count', type: 'number', label: 'Count' }, summary_table.map(&:count))

    builder.build.to_json
  end

  get '/:domain/boards/:board_id/cycle_time_summary.json' do
    series = (params[:series] || '').split(',')

    summary_table = @board.summarize

    builder = DataTableBuilder.new
      .column({type: 'string', label: 'Issue Type'}, summary_table.map(&:issue_type))
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

    builder.build.to_json
  end

  get '/:domain/boards/:board_id/control_chart.json' do
    trend_builder = TrendBuilder.new.
      pluck{ |issue| issue.cycle_time }.
      map do |issue, mean, stddev|
      { issue: issue, cycle_time: issue.cycle_time, mean: mean, stddev: stddev }
    end

    sorted_issues = @board.completed_issues.sort_by { |issue| issue.completed }
    ct_trends = trend_builder.analyze(sorted_issues)

    wip_history = @board.wip_history.map{ |date, issues| [date, issues.count] }
    trend_builder = TrendBuilder.new.
      pluck{ |item| item[1] }.
      map do |item, mean, stddev|
      {wip: item[1], mean: mean, stddev: stddev }
    end
    wip_trends = trend_builder.analyze(wip_history)

    {
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
    }.to_json
  end
end