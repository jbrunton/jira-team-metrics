module JiraTeamMetrics
  class Engine < ::Rails::Engine
    isolate_namespace JiraTeamMetrics

    require 'jquery-rails'
    require 'handlebars_assets'
    require 'less-rails'
    require 'less/rails/semantic_ui/engine'
    require 'autoprefixer-rails'
    require 'therubyracer'
    require 'lodash-rails'
    require 'coffee-rails'
    require 'draper'
    require 'descriptive_statistics'
    require 'open-uri'
    require 'parslet'
    require 'pickadate-rails'
    require 'gretel'

    config.after_initialize do
      unless ActiveRecord::Base.connection.migration_context.needs_migration?
        config_dir = ENV['CONFIG_DIR'] || 'config/'
        JiraTeamMetrics::ConfigFileService.new('jira-team-metrics.yml', config_dir).load_config
        JiraTeamMetrics::DatabaseService.new.prepare_database
      end
    end
  end
end
