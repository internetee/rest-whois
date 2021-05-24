source 'https://rubygems.org'

gem 'aws-sdk-ses', '~> 1.34'
gem 'bootsnap', require: false
gem 'figaro', '~> 1.1.0'
gem 'jbuilder'
gem 'mimemagic', '~> 0.3.10'
gem 'pg', '~> 1.0.0'
gem 'rails', '>= 6.0.3.1'
gem 'recaptcha', require: 'recaptcha/rails'
gem 'hcaptcha'
gem 'sassc', '~> 2.4'
gem 'sassc-rails'
gem 'simpleidn', '0.0.7' # For Punycode
gem 'uglifier'
gem 'passenger', '>= 5.3.2', require: 'phusion_passenger/rack_handler'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :development, :test do
  gem 'apparition'
  gem 'capybara'
  gem 'pry'
  gem 'unicorn'
  gem 'mina', '~> 0.3.8'
  gem 'puma'
  gem 'webmock'
end

group :test do
  gem 'selenium-webdriver'
  gem 'simplecov', '0.17.1', require: false # CC last supported v0.17
end
