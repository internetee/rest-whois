require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RestWhois
  class Application < Rails::Application
    config.load_defaults 8.1

    # Authorize all hosts
    config.hosts.clear

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.time_zone = ENV['time_zone']

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.yml').to_s]
    config.i18n.default_locale = :en
    config.i18n.fallbacks = [I18n.default_locale]

    config.secret_key_base = Figaro.env.secret_key_base

    # Mailer configuration
    config.action_mailer.default_url_options = { host: ENV['mailer_host'] }
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true

    config.action_controller.forgery_protection_origin_check = false

    config.action_mailer.smtp_settings = {
      address:              ENV['smtp_address'],
      port:                 ENV['smtp_port'],
      enable_starttls_auto: ENV['smtp_enable_starttls_auto'] == 'true',
      user_name:            ENV['smtp_user_name'],
      password:             ENV['smtp_password'],
      authentication:       ENV['smtp_authentication'],
      openssl_verify_mode:  ENV['smtp_openssl_verify_mode']
    }

    config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block',
        'X-Content-Type-Options' => 'nosniff',
        'X-Permitted-Cross-Domain-Policies' => 'none',
        'Referrer-Policy' => 'strict-origin-when-cross-origin'
    }

    # Deliberately off. The line used to say true, but it never took effect: on Rails 6.1 the
    # active_support railtie skipped the setting because ActiveSupport did not respond to it
    # yet at initializer time, so dates inside the whois json column have always been handed
    # to the views and to the json API as plain strings. Rails 8 does apply it, and turning it
    # on would silently change the date format of the public whois output - a product
    # decision, not something an upgrade gets to do on the side.
    config.active_support.parse_json_times = false
  end
end
