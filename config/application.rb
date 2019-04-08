# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WharehauoraServer
  class Application < Rails::Application
    # Use the responders controller from the responders gem
    config.app_generators.scaffold_controller :responders_controller

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1
    config.active_record.schema_format = :sql

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end

if ENV['WEBHOOK_SLACK_URL'].present?
  # notifier to slack channel when there an error in application
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    slack: {
      webhook_url: ENV['WEBHOOK_SLACK_URL'],
      additional_parameters: {
        mrkdwn: true
      }
    }
end
