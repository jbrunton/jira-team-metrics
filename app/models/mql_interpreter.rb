class MqlInterpreter

  def initialize(board)
    @board = board
  end

  def eval(query)
    parser = MqlParser.new
    transform = MqlTransform.new
    ast = transform.apply(parser.parse(query))
    ast.eval(@board.issues)
  end

  class MqlParser < Parslet::Parser
    rule(:identifier) { match('[a-zA-Z]').repeat(1) }
    rule(:operator)   { match('[=]') }
    rule(:filter)     { str('filter') >> operator.as(:op) >> string.as(:filter) }
    rule(:comparison) { identifier.as(:field) >> operator.as(:op) >> string.as(:string) }
    rule :string do
      str("'") >>
        (str("'").absent? >> any).repeat.as(:value) >>
        str("'")
    end
    rule(:expression) { filter | comparison }
    root(:expression)
  end

  class MqlTransform < Parslet::Transform
    rule(:string => subtree(:string)) { StringValue.new(string) }
    rule(
      :filter => subtree(:filter),
      :op => '=') { FilterExpr.new(filter) }
    rule(
      :field => simple(:field),
      :op => '=',
      :string => subtree(:string)) { Comparison.new(field, string) }
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
    def eval(issues)
      filter = Filter.find_by(name: filter_name[:value].to_s)
      issues.select do |issue|
        filter.include?(issue)
      end
    end
  end

  Comparison = Struct.new(:field, :value) do
    def eval(issues)
      issues.select do |issue|
        if issue.respond_to?(field.to_s)
          issue.send(field.to_s) == value[:value].to_s
        else
          false
        end
      end
    end
  end
end