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
gem 'email_validator'
gem 'sassc', '~> 2.4'
gem 'sassc-rails'
gem 'simpleidn', '0.2.1' # For Punycode
gem 'uglifier'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.9'
end

group :development, :test do
  gem 'capybara'
  gem 'mina', '~> 1.2.4'
  gem 'pry'
  gem 'puma'
  gem 'sqlite3', '~> 1.4'
  gem 'unicorn'
  gem 'webmock'
end

group :test do
  gem 'selenium-webdriver'
  gem 'simplecov', '0.17.1', require: false # CC last supported v0.17
end
