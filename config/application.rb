require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WharehauoraServer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end

if ENV['WEBHOOK_SLACK_URL'].present? and ENV['WEBHOOK_EMAIL_SENDER'].present? and ENV['WEBHOOK_EMAIL_RECIPIENT'].present?
  # notifier to slack channel when there an error in application
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: '[PREFIX]',
      sender_address: ENV['WEBHOOK_EMAIL_SENDER'],
      exception_recipients: ENV['WEBHOOK_EMAIL_RECIPIENT'].try(:split, ',')
    },
    slack: {
      webhook_url: ENV['WEBHOOK_SLACK_URL'],
      additional_parameters: {
        mrkdwn: true
      }
    }
end
