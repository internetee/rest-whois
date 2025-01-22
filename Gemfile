source 'https://rubygems.org'

gem 'aws-sdk-ses', '~> 1.40'
gem 'bootsnap', '~> 1.18.0', require: false
gem 'figaro', '~> 1.2.0'
gem 'jbuilder'
gem 'mimemagic', '~> 0.4.3'
gem 'passenger', '>= 5.3.2', require: 'phusion_passenger/rack_handler'
gem 'pg', '~> 1.5.0'
gem 'rails', '>= 6.0.3.1'
gem 'recaptcha', '~> 5.8', require: 'recaptcha/rails'
gem 'sassc', '~> 2.4'
gem 'sassc-rails'
gem 'simpleidn', '0.2.1' # For Punycode
gem 'uglifier'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.9'
end

group :development, :test do
  gem 'apparition', github: 'twalpole/apparition', ref: 'ca86be4d54af835d531dbcd2b86e7b2c77f85f34'
  gem 'capybara'
  gem 'mina', '~> 1.2.4'
  gem 'pry'
  gem 'puma'
  gem 'unicorn'
  gem 'webmock'
  gem 'bundler-audit'
  gem 'brakeman'
end

group :test do
  gem 'selenium-webdriver'
  gem 'simplecov', '0.17.1', require: false # CC last supported v0.17
end
