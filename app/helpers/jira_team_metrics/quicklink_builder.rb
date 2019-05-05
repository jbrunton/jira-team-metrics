class JiraTeamMetrics::QuicklinkBuilder
  include JiraTeamMetrics::ApplicationHelper
  include JiraTeamMetrics::Engine.routes.url_helpers

  attr_reader :report_name
  attr_reader :hierarchy_level
  attr_reader :from_date
  attr_reader :to_date
  attr_reader :query
  attr_reader :step_interval

  def initialize(opts)
    update(opts)
  end

  def set_defaults(today)
    case @report_name
      when 'throughput'
        set_throughput_defaults(today)
      when 'scatterplot'
        set_defaults_with_hierarchy_level(today)
      when 'cfd'
        set_defaults_with_hierarchy_level(today)
      else
        raise "Unexpected report_name: #{@report_name}"
    end
    self
  end

  def update(opts)
    FIELDS.each do |field|
      instance_variable_set("@#{field}", opts[field]) unless opts[field].nil?
    end
    self
  end

  def build_for(board)
    "#{Rails.application.config.relative_url_root}#{reports_path(board)}/#{@report_name}?#{build_opts(board).to_query}"
  end

  def self.throughput_quicklink(board, opts)
    JiraTeamMetrics::QuicklinkBuilder.new(opts)
      .update(report_name: 'throughput', step_interval: 'Monthly')
      .build_for(board)
  end

  def self.scatterplot_quicklink(board, opts)
    JiraTeamMetrics::QuicklinkBuilder.new(opts)
      .update(report_name: 'scatterplot')
      .build_for(board)
  end

  def self.cfd_quicklink(board, opts)
    JiraTeamMetrics::QuicklinkBuilder.new(opts)
      .update(report_name: 'cfd')
      .build_for(board)
  end

private

  FIELDS = [:report_name, :hierarchy_level, :from_date, :to_date, :query, :step_interval]

  def build_opts(board)
    opts = {
      from_date: format_mql_date(@from_date),
      to_date: format_mql_date(@to_date),
      hierarchy_level: @hierarchy_level,
    }
    opts.merge!(step_interval: @step_interval) unless @step_interval.nil?
    opts.merge!(query: build_query(board)) unless @query.nil?
    opts
  end

  def build_query(board)
    default_query = case @report_name
      when 'throughput'
        board.config.reports.throughput.default_query(@domain)
      when 'scatterplot'
        board.config.reports.scatterplot.default_query(@domain)
      else
        nil
    end
    JiraTeamMetrics::QueryBuilder.new(@query).and(default_query).query
  end

  def set_throughput_defaults(today)
    @to_date = today.at_beginning_of_month
    @from_date = @to_date - 6.months
    @step_interval = 'Monthly'
  end

  def set_defaults_with_hierarchy_level(today)
    @to_date = today
    if @hierarchy_level == 'Scope'
      @from_date = @to_date - 30
    else
      @from_date = @to_date - 90
    end
  end
end