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
    config.time_zone = ENV['time_zone']

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
    config.i18n.default_locale = :en

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    config.secret_key_base = Figaro.env.secret_key_base

    # Fallback to default locale if text is missing
    config.i18n.fallbacks = true

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

    config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block',
        'X-Content-Type-Options' => 'nosniff',
        'X-Permitted-Cross-Domain-Policies' => 'none',
        'Referrer-Policy' => 'strict-origin-when-cross-origin',
        'Content-Security-Policy' => "default-src 'self';" \
          "style-src 'self' 'unsafe-inline';" \
          "script-src https://www.google.com/recaptcha/ https://www.gstatic.com/recaptcha/;" \
          "frame-src 'self' https://www.google.com/recaptcha/",
    }
  end
end
