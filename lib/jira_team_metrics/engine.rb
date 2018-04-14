module JiraTeamMetrics
  class Engine < ::Rails::Engine
    isolate_namespace JiraTeamMetrics

    require 'jquery-rails'
    require 'handlebars_assets'
    require 'materialize-sass'
    require 'lodash-rails'
    require 'coffee-rails'

    #config.autoload_paths << File.expand_path("../../app/models/jira_team_metrics/jira", __FILE__)
  end
end
