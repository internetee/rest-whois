if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start 'rails'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

require 'minitest/mock'
require 'capybara/rails'
require 'capybara/minitest'
require 'webmock/minitest'
require 'support/captcha_helpers'

Capybara.default_normalize_ws = true

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  include CaptchaHelpers

  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include AbstractController::Translation

  setup do
    enable_captcha
  end

  teardown do
    WebMock.reset!
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
