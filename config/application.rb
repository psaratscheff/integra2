require File.expand_path('../boot', __FILE__)

require 'rails/all'

require 'twitter'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Integra2
  class Application < Rails::Application

    $client = Twitter::REST::Client.new do |config|
      config.consumer_key        = 'mAjo3eo9BkrjqOgg8IBnAkEMW'
      config.consumer_secret     = 'UYFFsbbuYPULzi6ZPkGdJXOOVLTZYCCHywyI0Rv1ofAGtYf23r'
      config.access_token        = '310049995-9WHiDYdslsvjsbgw7exFbOEPTN7gp8rqhdyp5wgg'
      config.access_token_secret = '6eNxzNnX3MwHH3tdyyd6buvyBOvfwtPPYG1Js04uBNctr'
    end

    config.to_prepare do
      # Load application's model / class decorators
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      # Load application's view overrides
      Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
