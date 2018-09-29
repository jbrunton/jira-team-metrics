class JiraTeamMetrics::MqlInterpreter

  def initialize(board, issues)
    @board = board
    @issues = issues
  end

  def eval(query)
    Rails.logger.info "Evaluating query: #{query}"
    return @issues if query.blank?

    parser = MqlParser.new
    transform = MqlTransform.new
    ast = transform.apply(parser.parse(query))
    ast.eval(@board, @issues)
  end

  class MqlParser < Parslet::Parser
    rule(:space)      { match('\s').repeat(1) }
    rule(:space?)     { space.maybe }

    rule(:and_operator) { str("and") >> space? }
    rule(:or_operator)  { str("or")  >> space? }
    rule(:kw_days) { (str('days') | str('day')) >> space? }
    rule(:lparen) { str("(") >> space? }
    rule(:rparen) { str(")") >> space? }
    rule(:comma)  { str(",") >> space? }
    rule(:digit) { match['0-9'] }

    rule(:integer) { (str('-').maybe >> digit.repeat(1)).as(:value) >> space? }
    rule(:identifier) { match('[a-zA-Z_]').repeat(1).as(:identifier) >> space? }
    rule(:operator)   { (str('=') | str('and') | str('includes') | str('<') | str('>')).as(:op) >> space? }
    rule(:filter)     { str('filter') >> space? >> operator >> string.as(:filter) }
    rule(:between)    { (str('between') >> space? >> lparen >> string.as(:left) >> comma >> string.as(:right) >> rparen).as(:between) }
    rule(:comparison) { (string | identifier).as(:field) >> operator >> string.as(:string) }
    rule(:date_comparison) { (string | identifier).as(:date_field) >> operator >> integer.as(:days) >> kw_days }
    rule(:contains) { (string | identifier).as(:field) >> operator >> string.as(:string) }
    rule :string do
      str("'") >>
        (str("'").absent? >> any).repeat.as(:value) >>
        str("'") >> space?
    end
    rule(:expression) { filter | comparison | date_comparison | not_expression | between | contains | boolean_expression | sort_expression }

    rule(:not_expression) { str('not') >> space? >> primary.as(:not) }

    rule(:primary) { lparen >> or_operation >> rparen | expression }

    rule(:boolean_expression) { (string | identifier).as(:bool) }

    rule(:and_operation) {
      (primary.as(:left) >> and_operator >>
        and_operation.as(:right)).as(:and) |
        primary }

    rule(:or_operation)  {
      (and_operation.as(:left) >> or_operator >>
        or_operation.as(:right)).as(:or) |
        and_operation }

    rule(:sort_clause) {
      str('sort by') >> space? >> (string | identifier).as(:sort_by) >> space? >> (str('desc') | str('asc')).as(:order)
    }

    rule(:sort_expression) { or_operation.as(:expression) >> space? >> sort_clause | or_operation }

    root(:sort_expression)
  end

  class MqlTransform < Parslet::Transform
    rule(:string => subtree(:string)) { StringValue.new(string) }
    rule(
      :filter => subtree(:filter),
      :op => '='
    ) {
      FilterExpr.new(filter)
    }
    rule(
      :between => { :left => subtree(:left), :right => subtree(:right) }
    ) {
      BetweenExpr.new(left, right)
    }
    rule(
      :field => subtree(:field),
      :op => '=',
      :string => subtree(:string)) { EqlComparison.new(field, string) }
    rule(
      :date_field => subtree(:date_field),
      :op => '>',
      :days => subtree(:days)) { DateComparison.new(date_field, days, '>') }
    rule(
      :date_field => subtree(:date_field),
      :op => '<',
      :days => subtree(:days)) { DateComparison.new(date_field, days, '<') }
    rule(
      :field => subtree(:field),
      :op => 'includes',
      :string => subtree(:string)) { Includes.new(field, string) }
    rule(
      :or => { :left => subtree(:left), :right => subtree(:right) }
    ) { OrExpr.new(left, right) }
    rule(
      :and => { :left => subtree(:left), :right => subtree(:right) }
    ) { AndExpr.new(left, right) }
    rule(
      :not => subtree(:expression)
    ) { NotExpr.new(expression) }
    rule(
      :expression => subtree(:expression),
      :sort_by => subtree(:sort_by),
      :order => subtree(:order)
    ) { SortExpr.new(expression, sort_by, order) }
    rule(
      :bool => subtree(:bool)
    ) { BooleanExpr.new(bool) }
    # ... other rules
  end

  FieldName = Struct.new(:name) do
    def eval
      name.to_s
    end
  end

  StringValue = Struct.new(:value) do
    def eval
      value.to_s
    end
  end

  FilterExpr = Struct.new(:filter_name) do
    def eval(board, issues)
      filter = board.filters.select{ |f| f.name == filter_name[:value].to_s }.first
      issues.select do |issue|
        filter.include?(issue)
      end
    end
  end

  BooleanExpr = Struct.new(:bool) do
    def eval(_, issues)
      issues.select do |issue|
        value = JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(field_name)
        !value.nil? || value
      end
    end

    def field_name
      @field_name ||= (bool[:identifier] || bool[:value]).to_s
    end
  end

  BetweenExpr = Struct.new(:lhs, :rhs) do
    def eval(_, issues)
      query_date_range = JiraTeamMetrics::DateRange.new(DateTime.parse(lhs[:value].to_s), DateTime.parse(rhs[:value].to_s))
      issues.select do |issue|
        issue_date_range = JiraTeamMetrics::DateRange.new(issue.started_time, issue.completed_time)
        issue_date_range.overlaps?(query_date_range)
      end
    end
  end

  OrExpr = Struct.new(:lhs, :rhs) do
    def eval(board, issues)
      lhs_issues = lhs.eval(board, issues)
      rhs_issues = rhs.eval(board, issues)
      (lhs_issues + rhs_issues).uniq
    end
  end

  AndExpr = Struct.new(:lhs, :rhs) do
    def eval(board, issues)
      lhs_issues = lhs.eval(board, issues)
      rhs_issues = rhs.eval(board, issues)
      lhs_issues.select{ |issue| rhs_issues.include?(issue) }
    end
  end

  NotExpr = Struct.new(:expr) do
    def eval(board, issues)
      exclude_issues = expr.eval(board, issues)
      issues.select{ |issue| !exclude_issues.include?(issue) }
    end
  end

  SortExpr = Struct.new(:expr, :sort_by, :order) do
    def eval(board, issues)
      sorted_issues = expr
        .eval(board, issues)
        .sort_by { |issue| sort_key_for(issue) }
      if order == 'desc'
        sorted_issues.reverse
      else
        sorted_issues
      end
    end

    def field_name
      @field_name ||= (sort_by[:identifier] || sort_by[:value]).to_s
    end

    def sort_key_for(issue)
      value = JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(field_name)
      if value.nil? then
        [0, nil]
      else
        [1, value]
      end
    end
  end

  Includes = Struct.new(:field, :value) do
    def eval(_, issues)
      issues.select do |issue|
        (JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(field_name) || []).include?(field_value)
      end
    end

    def field_name
      @field_name ||= (field[:identifier] || field[:value]).to_s
    end

    def field_value
      @field_value ||= value[:value].to_s
    end
  end

  EqlComparison = Struct.new(:field, :value) do
    def eval(_, issues)
      issues.select { |issue| compare_with(issue) }
    end

    def compare_with(issue)
      JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(field_name) == field_value
    end

    def field_name
      @field_name ||= (field[:identifier] || field[:value]).to_s
    end

    def field_value
      @field_value ||= value[:value].to_s
    end
  end

  DateComparison = Struct.new(:date_field, :days, :op) do
    def eval(_, issues)
      issues.select { |issue| compare_with(issue) }
    end

    def compare_with(issue)
      date = JiraTeamMetrics::IssueFieldResolver.new(issue).resolve(field_name)
      days = field_value
      case op
        when '>'
          !date.nil? && date > DateTime.now + days
        when '<'
          !date.nil? && date < DateTime.now + days
        else
          raise "Unexpected operator: #{op}"
      end
    end

    def field_name
      @field_name ||= (date_field[:identifier] || date_field[:value]).to_s
    end

    def field_value
      @field_value ||= days[:value].to_i
    end
  end
end