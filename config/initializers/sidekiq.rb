if defined?(Sidekiq) && Settings.redisUrl
  require "sidekiq/web"
  require "sidekiq/cron/web" if defined? Sidekiq::Cron

  Sidekiq.configure_server do |config|
    config.redis = {ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}}
  end

  Sidekiq.configure_client do |config|
    config.redis = {ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}}
  end

  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(Settings.sidekiq.user))
    ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(Settings.sidekiq.password))
  end

  if Sidekiq.server? && defined?(Sidekiq::Cron)
    Rails.application.config.after_initialize do
      schedule_file = Rails.root.join("config/schedule.yml")
      schedule_file_yaml = YAML.load_file(schedule_file) if schedule_file.exist?

      Sidekiq::Cron::Job.load_from_hash(schedule_file_yaml) if schedule_file_yaml.present?
    end
  end
end
