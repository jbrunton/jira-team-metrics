class JiraTeamMetrics::CfdChart
  include JiraTeamMetrics::ChartsHelper

  CfdRow = Struct.new(:to_do, :in_progress, :done, :predicted) do
    include JiraTeamMetrics::ChartsHelper

    def to_array(date)
      date_string = date_as_string(date)
      total = (done + in_progress + to_do + predicted)
      [date_string,
        0, # total displays as zero
        total, # total tooltip
        done,
        in_progress,
        to_do]
    end
  end

  def initialize(board, report_params)
    @board = board
    @params = report_params
  end

  def date_range
    @params.date_range
  end

  def data_table
    interpreter = JiraTeamMetrics::MqlInterpreter.new
    @scope = interpreter.eval(@params.query, @board, @board.issues).rows
      .select { |issue| issue.is_scope? }

    data_table = JiraTeamMetrics::DataTable.new([
      'Date', 'Total', 'Tooltip', 'Done', 'In Progress', 'To Do'
    ], [])

    dates = date_range.to_a

    dates.each do |date|
      data_table.add_row [date_as_string(date), 0, 0, 0, 0, 0]
    end

    @scope.each do |issue|
      completed_time = issue.completed_time || date_range.end_date + 1
      started_time = issue.started_time || completed_time
      created_time = issue.issue_created

      dates.each_with_index do |date, index|
        if created_time <= date && date < started_time
          data_table.rows[index][5] += 1
        elsif started_time <= date && date < completed_time
          data_table.rows[index][4] += 1
        elsif completed_time <= date
          data_table.rows[index][3] += 1
        end
        data_table.rows[index][2] += 1 unless created_time > date
      end
    end

    data_table
  end

  def chart_opts
    {
      chartArea: {
        width: '90%',
        height: '80%',
        top: '5%'
      },
      height: 500,
      hAxis: {titleTextStyle: {color: '#333'}},
      vAxis: {minValue: 0, textPosition: 'none'},
      isStacked: true,
      lineWidth: 1,
      areaOpacity: 0.4,
      legend: { position: 'top' },
      series: {
        0 => { color: 'grey' },
        1 => { color: 'blue' },
        2 => { color: 'green' },
        3 => { color: 'red' },
        4 => { color: 'orange' }
      },
      crosshair: { trigger: 'focus', orientation: 'vertical', color: 'grey' },
      focusTarget: 'category',
      annotations: {
        textStyle: {
          color: 'black'
        },
        domain: {
          style: 'line',
          stem: {
            color: 'red',
          }
        },
        datum: {
          style: 'point',
          stem: {
            color: 'black',
            length: '12'
          }
        }
      }
    }
  end

  def json_data
    {
      chartOpts: chart_opts,
      data: data_table.to_json('Date' => { type: 'date' }, 'Tooltip' => { role: 'tooltip' })
    }
  end

  def build_header
    [
      {'label' => 'Date', 'type' => 'date', 'role' => 'domain'},
      'Total',
      {'type' => 'string', 'role' => 'tooltip'}, # annotation for 'Total'
      'Done',
      'In Progress',
      'To Do'
    ]
  end

  private

  def cfd_row_for(date)
    row = CfdRow.new(0, 0, 0, 0)

    @scope.each do |issue|
      case issue.status_category_on(date)
        when 'To Do'
          row.to_do += 1
        when 'In Progress'
          row.in_progress += 1
        when 'Done'
          row.done += 1
        when 'Predicted'
          row.predicted += 1
      end
    end

    row
  end
end