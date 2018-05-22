require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RestWhois
  class Application < Rails::Application
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
    config.secret_key_base = Figaro.env.secret_key_base

    # Mailer configuration
    config.action_mailer.default_url_options = { host: ENV['mailer_host'] }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true

    config.action_mailer.smtp_settings = {
      address:              ENV['smtp_address'],
      port:                 ENV['smtp_port'],
      enable_starttls_auto: ENV['smtp_enable_starttls_auto'] == 'true',
      user_name:            ENV['smtp_user_name'],
      password:             ENV['smtp_password'],
      authentication:       ENV['smtp_authentication'],
      domain:               ENV['smtp_domain'],
      openssl_verify_mode:  ENV['smtp_openssl_verify_mode']
    }
  end
end
