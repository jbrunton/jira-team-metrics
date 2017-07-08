class Parser

  def parse(input)
    MqlParser.new.parse(input)
  end

  class MqlParser < Parslet::Parser
    rule(:field) { match('[a-zA-Z]').repeat(1) }
    rule(:operator)   { match('[=]') }
    rule(:string)     { match("'a'") }
    rule(:comparison) { field.as(:field) >> operator.as(:op) >> string.as(:string) }
    rule :string do
      str("'") >>
        (str("'").absent? >> any).repeat.as(:value) >>
        str("'")
    end
    root(:comparison)
  end

  class MqlTransform < Parslet::Transform
    rule(:string => subtree(:string)) { StringValue.new(string) }
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