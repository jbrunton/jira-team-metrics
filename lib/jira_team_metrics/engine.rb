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
    require 'humanize'
    require 'dry-struct'

    config.after_initialize do
      unless ActiveRecord::Base.connection.migration_context.needs_migration?
        JiraTeamMetrics::DatabaseService.new.prepare_database
        JiraTeamMetrics::ConfigFileService.load_domain_config
      end
    end
  end
end
