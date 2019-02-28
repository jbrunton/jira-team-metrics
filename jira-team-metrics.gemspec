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

  s.files = Dir["{app,config,db,lib,vendor}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", ">= 5.0.0"
  s.add_dependency "jquery-rails"
  s.add_dependency "handlebars_assets"
  s.add_dependency "less-rails-semantic_ui"
  s.add_dependency "autoprefixer-rails"
  s.add_dependency "therubyracer"
  s.add_dependency "lodash-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "draper", "~> 3.0.0"
  s.add_dependency "descriptive_statistics"
  s.add_dependency "parslet"
  s.add_dependency "less-rails"
  s.add_dependency "pickadate-rails"
  s.add_dependency "gretel"
  s.add_dependency "humanize"

  s.add_development_dependency "sqlite3", '1.3.13'
  s.add_development_dependency "byebug"
  s.add_development_dependency "puma"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "factory_bot_rails", "4.11.1" # for some reason 5.0 raises a FactoryBot::DuplicateDefinitionError
  s.add_development_dependency "simplecov"
  s.add_development_dependency "rails-controller-testing"
end
