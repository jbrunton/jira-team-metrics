module JiraTeamMetrics::MqlLexer
  include Parslet

  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  rule(:digit) { match['0-9'] }
  rule(:int) { (str('-').maybe >> digit.repeat(1)).as(:int) >> space? }
  rule(:bool) { (str('true') | str('false')).as(:bool) >> space? }

  rule(:ident) do
    (
      (match('[a-zA-Z_]') >> match('[a-zA-Z0-9_]').repeat).as(:ident) |
        str("[") >>
          (str("]").absent? >> any).repeat.as(:ident) >>
          str("]")
    ) >> space?
  end

  rule :string do
    str("'") >>
        (str("'").absent? >> any).repeat.as(:str) >>
        str("'") >> space?
  end
end
