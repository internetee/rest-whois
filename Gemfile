source 'https://rubygems.org'

# Ruby 3.4 moved these out of the default gems; Rails 6.1 does not declare
# them, so they must be required explicitly to boot on Ruby 3.4.
gem 'base64'
gem 'benchmark'
gem 'bigdecimal'
gem 'drb'
gem 'logger'
gem 'mutex_m'
gem 'net-smtp', require: false
gem 'ostruct'
gem 'syslog' # Used by production logging (syslog/logger); bundled gem in Ruby 3.4

gem 'aws-sdk-ses', '~> 1.40'
gem 'bootsnap', '~> 1.18.0', require: false
gem 'figaro', '~> 1.3.0'
gem 'jbuilder'
gem 'mimemagic', '~> 0.4.3'
gem 'passenger', '>= 5.3.2', require: 'phusion_passenger/rack_handler'
gem 'pg', '~> 1.6.3', force_ruby_platform: true
gem 'rails', '~> 6.1.7', '>= 6.1.7.10'
gem 'recaptcha', '~> 5.21', require: 'recaptcha/rails'
gem 'sassc', '~> 2.4'
gem 'sassc-rails'
gem 'simpleidn', '0.2.1' # For Punycode
gem 'uglifier'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.10.1'
end

group :development, :test do
  gem 'apparition', github: 'twalpole/apparition', ref: 'ca86be4d54af835d531dbcd2b86e7b2c77f85f34'
  gem 'capybara'
  gem 'matrix' # Removed from Ruby 3.4 default gems; required by capybara
  gem 'mina', '~> 1.2.4'
  gem 'pry'
  gem 'puma'
  gem 'unicorn'
  gem 'webmock'
end

group :test do
  gem 'minitest', '~> 5.25' # Rails 6.1 is built against minitest 5.x; 6.x breaks minitest/mock
  gem 'selenium-webdriver'
  gem 'simplecov', '0.17.1', require: false # CC last supported v0.17
end
