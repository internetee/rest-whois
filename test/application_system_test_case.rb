require 'test_helper'

WebMock.disable_net_connect!(allow_localhost: true)

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  Capybara.register_driver(:headless_chrome) do |app|
    options = ::Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--window-size=1400,1400')

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  driven_by :headless_chrome
  Capybara.server = :puma, { Silent: true }
end
