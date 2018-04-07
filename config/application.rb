require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module JiraTeamMetrics
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.autoload_paths << Rails.root.join("lib")
    config.autoload_paths << Rails.root.join("app", "models", "stats")
    config.autoload_paths << Rails.root.join("app", "models", "stats", "scope")
    config.autoload_paths << Rails.root.join("app", "models", "jira")
    config.autoload_paths << Rails.root.join("app", "models", "config")

    config.after_initialize do
      unless ENV['CONFIG_URL'].nil?
        log_message = "CONFIG_URL defined. Setting config from #{ENV['CONFIG_URL']}"
        Rails.logger.info log_message
        puts log_message # Rails doesn't print to stdout during boot

        domain = Domain.get_instance
        domain.config_string = open(ENV['CONFIG_URL']).read
        unless domain.save
          raise 'Invalid config: ' + domain.errors.full_messages.join(',')
        end
      end
    end
  end
end
