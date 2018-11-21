module JiraTeamMetrics::MqlLexer
  include Parslet

  rule(:space)      { match('\s').repeat(1) }
  rule(:space?)     { space.maybe }

  rule(:digit) { match['0-9'] }
  rule(:integer) { (str('-').maybe >> digit.repeat(1)).as(:value) >> space? }
  rule(:identifier) { (match('[a-zA-Z_]') >> match('[a-zA-Z0-9_]').repeat).as(:identifier) >> space? }
  rule :string do
    str("'") >>
        (str("'").absent? >> any).repeat.as(:value) >>
        str("'") >> space?
  end

  rule(:token) { integer | identifier | string }
end
