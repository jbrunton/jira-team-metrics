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
      unless ENV['CONFIG_URL'].nil?
        log_message = "CONFIG_URL defined. Setting config from #{ENV['CONFIG_URL']}"
        Rails.logger.info log_message
        puts log_message # Rails doesn't print to stdout during boot

        domain = JiraTeamMetrics::Domain.get_instance
        domain.config_string = open(ENV['CONFIG_URL']).read
        unless domain.save
          raise 'Invalid config: ' + domain.errors.full_messages.join(',')
        end
      end
    end
  end
end
