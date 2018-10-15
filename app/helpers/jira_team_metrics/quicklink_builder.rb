class JiraTeamMetrics::QuicklinkBuilder
  include JiraTeamMetrics::ApplicationHelper
  include JiraTeamMetrics::Engine.routes.url_helpers

  def initialize(report_name, hierarchy_level)
    @report_name = report_name
    @hierarchy_level = hierarchy_level
  end

  def from_date(from_date)
    @from_date = from_date
    self
  end

  def to_date(to_date)
    @to_date = to_date
    self
  end

  def query(query)
    @query = query
    self
  end

  def step_interval(step_interval)
    @step_interval = step_interval
    self
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
    self
  end

  def build_for(board)
    "#{reports_path(board)}/#{@report_name}?#{build_opts.to_query}"
  end

private

  def build_opts
    opts = {
      from_date: format_mql_date(@from_date),
      to_date: format_mql_date(@to_date),
      hierarchy_level: @hierarchy_level,
    }
    opts.merge!(step_interval: @step_interval) unless @step_interval.nil?
    opts.merge!(query: @query) unless @query.nil?
    opts
  end

  def set_throughput_defaults(today)
    @to_date = today.at_beginning_of_month + 1.month
    @from_date = @to_date - 6.months
    @step_interval = 'Monthly'
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