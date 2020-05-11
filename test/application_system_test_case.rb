require 'test_helper'
require 'capybara/apparition'

WebMock.disable_net_connect!(allow_localhost: true) # `allow_localhost` is required by Selenium

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include CaptchaHelpers

  # Moved from Selenium to Apparition driver due to Selenium intentionally lacks page.status
  Capybara.register_driver(:headless_apparition) do |app|
    Capybara::Apparition::Driver.new(app)
  end

  driven_by :headless_apparition
  Capybara.server = :puma, { Silent: true }

  def whitelist_current_ip
    ENV['whitelist_ip'] = '127.0.0.1'
  end

  setup do
    enable_captcha
  end
end
