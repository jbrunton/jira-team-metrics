class JiraTeamMetrics::QuicklinkBuilder
  include JiraTeamMetrics::ApplicationHelper
  include JiraTeamMetrics::Engine.routes.url_helpers

  attr_reader :hierarchy_level
  attr_reader :from_date
  attr_reader :to_date
  attr_reader :step_interval

  def initialize(report_name, hierarchy_level, today)
    @report_name = report_name
    @hierarchy_level = hierarchy_level
    set_defaults(today)
  end

  def from_date(from_date)
    @from_date = from_date
  end

  def to_date(to_date)
    @to_date = to_date
  end

  def build_for(board)
    "#{reports_path(board)}/#{@report_name}?#{build_opts.to_query}"
  end

private

  def build_opts
    {
      from_date: format_mql_date(@from_date),
      to_date: format_mql_date(@to_date),
      step_interval: @step_interval
    }
  end

  def set_defaults(today)
    case @report_name
      when 'throughput'
        set_throughput_defaults(today)
      when 'scatterplot'
        set_scatterplot_defaults(today)
      else
        raise "Unexpected report_name: #{@report_name}"
    end
  end

  def set_throughput_defaults(today)
    @to_date = today.at_beginning_of_month
    @from_date = @to_date - 6.months
  end

  def set_scatterplot_defaults(today)
    @to_date = today
    if @hierarchy_level == 'Scope'
      @from_date = @to_date - 30
    else
      @from_date = @to_date - 90
    end
  end
end