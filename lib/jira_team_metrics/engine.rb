module JiraTeamMetrics
  class Engine < ::Rails::Engine
    isolate_namespace JiraTeamMetrics

    require 'jquery-rails'
    require 'handlebars_assets'
    require 'materialize-sass'
    require 'lodash-rails'
    require 'coffee-rails'
    require 'draper'
    require 'descriptive_statistics'
    require 'open-uri'

    config.autoload_paths << File.expand_path("../../../app/models/jira_team_metrics/stats", __FILE__)
    config.autoload_paths << File.expand_path("../../../app/models/jira_team_metrics/stats/scope", __FILE__)
    config.autoload_paths << File.expand_path("../../../app/models/jira_team_metrics/reports", __FILE__)
  end
end
