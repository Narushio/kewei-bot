require_relative "boot"

require "rails/all"
require_relative "../lib/bot"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module KeweiBot
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0
    config.time_zone = "Beijing"
    config.active_record.default_timezone = :local

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.autoload_paths << "#{root}/lib"
    config.i18n.default_locale = :"zh-CN"

    if Sidekiq.server?
      Thread.new {
        sleep 1
        Bot.new
      }.run
    end
  end
end
