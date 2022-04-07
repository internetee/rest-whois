source 'https://rubygems.org'

gem 'aws-sdk-ses', '~> 1.40'
gem 'bootsnap', '~> 1.11.0', require: false
gem 'figaro', '~> 1.2.0'
gem 'jbuilder'
gem 'mimemagic', '~> 0.4.3'
gem 'pg', '~> 1.3.0'
gem 'rails', '>= 6.0.3.1'
gem 'recaptcha', '~> 5.8', require: 'recaptcha/rails'
gem 'sassc', '~> 2.4'
gem 'sassc-rails'
gem 'simpleidn', '0.2.1' # For Punycode
gem 'uglifier'
gem 'passenger', '>= 5.3.2', require: 'phusion_passenger/rack_handler'

group :development do
  gem 'listen', '>= 3.0.5', '< 3.8'
end

group :development, :test do
  gem 'apparition'
  gem 'capybara'
  gem 'pry'
  gem 'unicorn'
  gem 'mina', '~> 1.2.4'
  gem 'puma'
  gem 'webmock'
end

group :test do
  gem 'selenium-webdriver'
  gem 'simplecov', '0.17.1', require: false # CC last supported v0.17
end
