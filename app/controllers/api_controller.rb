class ApiController < ApplicationController
  get '/:domain/boards/:board_id/count_summary.json' do
    summary_table = @board.summarize

    builder = DataTableBuilder.new
      .column({id: 'issue_type', type: 'string', label: 'Issue Type'})
      .column({id: 'count', type: 'number', label: 'Count' })

    summary_table.each do |row|
      builder.row([row.issue_type, row.count])
    end

    builder.build.to_json
  end

  get '/:domain/boards/:board_id/cycle_time_summary.json' do
    series = (params[:series] || '').split(',')

    summary_table = @board.summarize

    builder = DataTableBuilder.new
      .column({type: 'string', label: 'Issue Type'})
      .number({label: 'Mean', id: 'mean'})
      .number({label: 'Median', id: 'median'})

    if series.include?('min-max')
      builder.number({id: 'min', label: 'Min'})
      builder.number({id: 'max', label: 'Max'})
    end

    builder.number({id: 'p25', label: 'Lower Quartile'})
    builder.number({id: 'p75', label: 'Upper Quartile'})

    if series.include?('p10-p90')
      builder.number({id: 'p10', label: '10th Percentile'})
      builder.number({id: 'p90', label: '90th Percentile'})
      builder.intervals(['i:p10', 'i:p90'])
    end

    builder.intervals(['i:p25', 'i:median', 'i:p75'])

    summary_table.map do |row|
      values = [row.issue_type, row.ct_mean, row.ct_median]

      if series.include?('min-max')
        values.concat([row.ct_min, row.ct_max])
      end

      values.concat([row.ct_p25, row.ct_p75])

      if series.include?('p10-p90')
        values.concat([row.ct_p10, row.ct_p90, row.ct_p10, row.ct_p90])
      end

      values.concat([row.ct_p25, row.ct_median, row.ct_p75])

      builder.row(values)
    end

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