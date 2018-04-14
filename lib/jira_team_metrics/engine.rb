module JiraTeamMetrics
  class Engine < ::Rails::Engine
    isolate_namespace JiraTeamMetrics
    require 'jquery-rails'
    require 'handlebars_assets'
    require 'materialize-sass'
    require 'lodash-rails'
    require 'coffee-rails'
  end
end
