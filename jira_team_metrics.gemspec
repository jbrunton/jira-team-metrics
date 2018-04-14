$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "jira_team_metrics/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "jira_team_metrics"
  s.version     = JiraTeamMetrics::VERSION
  s.authors     = ["John Brunton"]
  s.email       = ["jbrunton@zipcar.com"]
  s.homepage    = "https://github.com/jbrunton/jira-team-metrics"
  s.summary     = "Summary of JiraTeamMetrics."
  s.description = "Description of JiraTeamMetrics."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.1.4"

  s.add_dependency "jquery-rails"
  s.add_dependency "handlebars_assets"
  s.add_dependency "materialize-sass", "~> 0.99.0"
  s.add_dependency "lodash-rails"
  s.add_dependency "coffee-rails"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "byebug"
end
