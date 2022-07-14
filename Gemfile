source "https://gems.ruby-china.com"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.2"

gem "rails", "~> 7.0.2", ">= 7.0.2.3"
gem "sprockets-rails"
gem "mysql2", "~> 0.5"
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "webdrivers", "~> 5.0"
gem "config"
gem "rmagick"
gem "bootsnap", require: false
gem "faraday"
gem "faye-websocket"
gem "nokogiri"
gem "down"
gem "redis", "~> 4.5.1"
gem "sidekiq"
gem "sidekiq-cron"

group :development, :test do
  gem "standardrb"
  gem "byebug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
end
