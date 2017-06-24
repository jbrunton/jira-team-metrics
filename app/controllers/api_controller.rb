class ApiController < ApplicationController
  get '/:domain/boards/:board_id/count_summary.json' do
    summary_table = @board.summarize
    {
      cols: [
        {id: 'issue_type', type: 'string', label: 'Issue Type' },
        {id: 'count', type: 'number', label: 'Count' }
      ],
      rows: summary_table.map do |row|
        {c: [{v: row.issue_type}, {v: row.count}]}
      end
    # rows: [
    #   {c: [{v: 'Story'}, {v: 4}]},
    #   {c: [{v: 'Bugs'}, {v: 6}]}
    # ]
    }.to_json
  end

  get '/:domain/boards/:board_id/cycle_time_summary.json' do
    series = (params[:series] || '').split(',')

    summary_table = @board.summarize

    cols = [
      {type: 'string', label: 'Issue Type'},
      {type: 'number', label: 'Mean', id: 'mean'}
    ]

    if series.include?('p10-p90')
      cols << {type: 'number', role: 'interval', id: 'p10'}
      cols << {type: 'number', role: 'interval', id: 'p90'}
    end

    if series.include?('p25-p75')
      cols << {type: 'number', role: 'interval', id: 'p25'}
    end

    cols << {type: 'number', role: 'interval', id: 'median'}

    if series.include?('p25-p75')
      cols << {type: 'number', role: 'interval', id: 'p75'}
    end

    if series.include?('min-max')
      cols << {type: 'number', role: 'interval', id: 'min'}
      cols << {type: 'number', role: 'interval', id: 'max'}
    end


    # summary_table.each do |row|
    #   issue_type = row.issue_type
    #   cols << {id: issue_type, type: 'number', label: issue_type }
    #   cols << {id: issue_type + '_i0', type: 'number', role: 'interval' }
    #   cols << {id: issue_type + '_i1', type: 'number', role: 'interval' }
    # end

    {
      cols: cols,
      rows: summary_table.map do |row|
        values = [
          {v: row.issue_type},
          {v: row.ct_mean}
        ]

        if series.include?('p10-p90')
          values << {v: row.ct_p10}
          values << {v: row.ct_p90}
        end

        if series.include?('p25-p75')
          values << {v: row.ct_p25}
        end

        values << {v: row.ct_median}

        if series.include?('p25-p75')
          values << {v: row.ct_p75}
        end

        if series.include?('min-max')
          values << {v: row.ct_min}
          values << {v: row.ct_max}
        end

        {c: values}
      end
    }.to_json
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