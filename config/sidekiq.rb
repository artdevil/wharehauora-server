redis_url = case Rails.env
            when 'development'
              'redis://localhost:6379/3'
            when 'production'
              ENV['REDIS_PROVIDER']
            when 'staging'
              ENV['REDIS_PROVIDER']
            end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  config.error_handlers << Proc.new do |ex, context|
    ExceptionNotifier.notify_exception(ex, data: { sidekiq: context })
  end
end
